/* Copyright (C) 2010-2013 Ian MacLarty. See Copyright Notice in lt.h. */
#include "lt.h"

LT_INIT_IMPL(ltevent)

LTEventHandler::LTEventHandler(int filter, LTfloat left, LTfloat bottom, LTfloat right, LTfloat top) {
    bb = new LTEventHandlerBB();
    bb->left = left;
    bb->bottom = bottom;
    bb->right = right;
    bb->top = top;
    LTEventHandler::filter = filter;
    execution_pending = false;
    cancelled = false;
}

LTEventHandler::LTEventHandler(int filter) {
    bb = NULL;
    LTEventHandler::filter = filter;
    execution_pending = false;
    cancelled = false;
}

LTEventHandler::~LTEventHandler() {
    assert(!execution_pending);
    if (bb != NULL) {
        delete bb;
    }
}

bool LTEventHandler::hit(LTEvent *e) {
    //ltLog("hit test: %x, %x, %f, %f", e->event, filter, e->x, e->y);
    if (bb != NULL
        && LT_EVENT_MATCH(e->event, LT_EVENT_POINTER_MOVE)
        && LT_EVENT_MATCH(filter, LT_EVENT_POINTER_ENTER)
        // prev position outside
        && (e->prev_x < bb->left || e->prev_x > bb->right || e->prev_y < bb->bottom || e->prev_y > bb->top)
        // new position inside
        && (e->x >= bb->left && e->x <= bb->right && e->y >= bb->bottom && e->y <= bb->top))
    {
        e->event |= LT_EVENT_POINTER_ENTER;
        return ((filter & e->event) == filter);
    } else if (bb != NULL
        && LT_EVENT_MATCH(e->event, LT_EVENT_POINTER_MOVE)
        && LT_EVENT_MATCH(filter, LT_EVENT_POINTER_EXIT)
        // new position outside
        && (e->x < bb->left || e->x > bb->right || e->y < bb->bottom || e->y > bb->top)
        // prev position inside
        && (e->prev_x >= bb->left && e->prev_x <= bb->right && e->prev_y >= bb->bottom && e->prev_y <= bb->top))
    {
        e->event |= LT_EVENT_POINTER_EXIT;
        return ((filter & e->event) == filter);
    } else {
        return (LT_EVENT_MATCH(e->event, filter) &&
            ( bb == NULL || (e->x >= bb->left && e->x <= bb->right && e->y >= bb->bottom && e->y <= bb->top) ));
    }
}

LTSceneNode *lt_exclusive_receiver = NULL;

struct LTEventVisitor : LTSceneNodeVisitor {
    LTEvent *event;
    bool events_allowed;
    LTSceneNode *exclusive_node;
    std::list<LTEvent*> events_to_execute;

    LTEventVisitor(LTEvent *e) {
        event = e;
        exclusive_node = lt_exclusive_receiver;
        events_allowed = (exclusive_node == NULL);
    }
    virtual void visit(LTSceneNode *node) {
        if (node->action_speed == 0.0f) {
            // Ignore paused nodes and their children.
            return;
        }
        bool prev_allowed = events_allowed;
        if (exclusive_node != NULL && node == exclusive_node) {
            events_allowed = true;
        }
        bool consumed = false;
        if (events_allowed) {
            if (node->event_handlers != NULL) {
                std::list<LTEventHandler*>::iterator it;
                for (it = node->event_handlers->begin(); it != node->event_handlers->end(); it++) {
                    LTEventHandler *handler = *it;
                    int e = event->event;
                    if (handler->hit(event)) {
                        LTEvent *event_with_handler = new LTEvent(event);
                        event_with_handler->node = node;
                        event_with_handler->handler = handler;
                        events_to_execute.push_back(event_with_handler);
                        handler->execution_pending = true;
                        consumed = true;
                    }
                    event->event = e; // call to hit() may alter event
                }
            }
        }
        if (!consumed) {
            LTfloat old_x = 0, old_y = 0, old_prev_x = 0, old_prev_y = 0;
            if (LT_EVENT_MATCH(event->event, LT_EVENT_POINTER)) {
                old_x = event->x;
                old_y = event->y;
                old_prev_x = event->prev_x;
                old_prev_y = event->prev_y;
                if (!node->inverse_transform(&event->prev_x, &event->prev_y)) {
                    return;
                }
                if (!node->inverse_transform(&event->x, &event->y)) {
                    return;
                }
            }
            node->visit_children(this, true);
            if (LT_EVENT_MATCH(event->event, LT_EVENT_POINTER)) {
                event->x = old_x;
                event->y = old_y;
                event->prev_x = old_prev_x;
                event->prev_y = old_prev_y;
            }
        }
        events_allowed = prev_allowed;
    }
};

void ltPropagateEvent(LTSceneNode *node, LTEvent *event) {
    LTEventVisitor v(event);
    v.visit(node);
    std::list<LTEvent*>::iterator it;
    std::set<LTEventHandler *> cancelled_handlers;
    bool consumed = false;
    for (it = v.events_to_execute.begin(); it != v.events_to_execute.end(); it++) {
        LTEvent *e = *it;
        LTEventHandler *h = e->handler;
        if (h->cancelled) {
            cancelled_handlers.insert(h);
        } else if (h->execution_pending) {
            if (!consumed) {
                consumed = h->consume(e->node, e);
            }
            h->execution_pending = false;
        }
        delete e;
    }
    std::set<LTEventHandler *>::iterator cit;
    for (cit = cancelled_handlers.begin(); cit != cancelled_handlers.end(); cit++) {
        delete *cit;
    }
}

LT_REGISTER_TYPE(LTEvent, "lt.Event", "lt.Object")
LT_REGISTER_FIELD_FLOAT(LTEvent, x)
LT_REGISTER_FIELD_FLOAT(LTEvent, y)
LT_REGISTER_FIELD_FLOAT(LTEvent, orig_x)
LT_REGISTER_FIELD_FLOAT(LTEvent, orig_y)
LT_REGISTER_FIELD_INT(LTEvent, button)
LT_REGISTER_FIELD_INT_AS(LTEvent, touch_id, "touch")

static const LTEnumConstant key_enum_vals[] = {
    {"unknown", LT_KEY_UNKNOWN},
    {"0", LT_KEY_0},
    {"1", LT_KEY_1},
    {"2", LT_KEY_2},
    {"3", LT_KEY_3},
    {"4", LT_KEY_4},
    {"5", LT_KEY_5},
    {"6", LT_KEY_6},
    {"7", LT_KEY_7},
    {"8", LT_KEY_8},
    {"9", LT_KEY_9},
    {"a", LT_KEY_a},
    {"b", LT_KEY_b},
    {"c", LT_KEY_c},
    {"d", LT_KEY_d},
    {"e", LT_KEY_e},
    {"f", LT_KEY_f},
    {"g", LT_KEY_g},
    {"h", LT_KEY_h},
    {"i", LT_KEY_i},
    {"j", LT_KEY_j},
    {"k", LT_KEY_k},
    {"l", LT_KEY_l},
    {"m", LT_KEY_m},
    {"n", LT_KEY_n},
    {"o", LT_KEY_o},
    {"p", LT_KEY_p},
    {"q", LT_KEY_q},
    {"r", LT_KEY_r},
    {"s", LT_KEY_s},
    {"t", LT_KEY_t},
    {"u", LT_KEY_u},
    {"v", LT_KEY_v},
    {"w", LT_KEY_w},
    {"x", LT_KEY_x},
    {"y", LT_KEY_y},
    {"z", LT_KEY_z},
    {"A", LT_KEY_A},
    {"B", LT_KEY_B},
    {"C", LT_KEY_C},
    {"D", LT_KEY_D},
    {"E", LT_KEY_E},
    {"F", LT_KEY_F},
    {"G", LT_KEY_G},
    {"H", LT_KEY_H},
    {"I", LT_KEY_I},
    {"J", LT_KEY_J},
    {"K", LT_KEY_K},
    {"L", LT_KEY_L},
    {"M", LT_KEY_M},
    {"N", LT_KEY_N},
    {"O", LT_KEY_O},
    {"P", LT_KEY_P},
    {"Q", LT_KEY_Q},
    {"R", LT_KEY_R},
    {"S", LT_KEY_S},
    {"T", LT_KEY_T},
    {"U", LT_KEY_U},
    {"V", LT_KEY_V},
    {"W", LT_KEY_W},
    {"X", LT_KEY_X},
    {"Y", LT_KEY_Y},
    {"Z", LT_KEY_Z},

    {"space", LT_KEY_SPACE},
    {"tab", LT_KEY_TAB},
    {"enter", LT_KEY_ENTER},
    {"up", LT_KEY_UP},
    {"down", LT_KEY_DOWN},
    {"left", LT_KEY_LEFT},
    {"right", LT_KEY_RIGHT},
    {"[", LT_KEY_LEFT_BRACKET},
    {"]", LT_KEY_RIGHT_BRACKET},
    {"\\", LT_KEY_BACKSLASH},
    {";", LT_KEY_SEMI_COLON},
    {"'", LT_KEY_APOS},
    {",", LT_KEY_COMMA},
    {".", LT_KEY_PERIOD},
    {"/", LT_KEY_SLASH},
    {"+", LT_KEY_PLUS},
    {"-", LT_KEY_MINUS},
    {"`", LT_KEY_TICK},
    {"del", LT_KEY_DEL},
    {"esc", LT_KEY_ESC},
    {"back", LT_KEY_BACK},

    {"~", LT_KEY_TILDE},
    {"!", LT_KEY_EXCLAMATION},
    {"@", LT_KEY_ATRATE},
    {"#", LT_KEY_HASH},
    {"$", LT_KEY_DOLLAR},
    {"%", LT_KEY_PERCENT},
    {"^", LT_KEY_CARET},
    {"&", LT_KEY_AMPERSAND},
    {"*", LT_KEY_ASTERISK},
    {"(", LT_KEY_LEFT_ROUND_BRACKET},
    {")", LT_KEY_RIGHT_ROUND_BRACKET},
    {"_", LT_KEY_UNDERSCORE},
    {"=", LT_KEY_EQUALS},
    {"{", LT_KEY_LEFT_CURLY},
    {"}", LT_KEY_RIGHT_CURLY},
    {":", LT_KEY_COLON},
    {"\"", LT_KEY_QUOTES},
    {"<", LT_KEY_LEFT_ANGLE},
    {">", LT_KEY_RIGHT_ANGLE},
    {"?", LT_KEY_QUESTION},
    {"|", LT_KEY_PIPE},

    {NULL, 0}};
LT_REGISTER_FIELD_ENUM(LTEvent, key, LTKey, key_enum_vals)

static const LTEnumConstant event_enum_vals[] = {
    {"touch_down", LT_EVENT_TOUCH_DOWN},
    {"touch_up",   LT_EVENT_TOUCH_UP},
    {"touch_move", LT_EVENT_TOUCH_MOVE},
    {"mouse_down", LT_EVENT_MOUSE_DOWN},
    {"mouse_up",   LT_EVENT_MOUSE_UP},
    {"mouse_move", LT_EVENT_MOUSE_MOVE},
    {"key_down",   LT_EVENT_KEY_DOWN},
    {"key_up",     LT_EVENT_KEY_UP},
    {NULL, 0}};
LT_REGISTER_FIELD_ENUM(LTEvent, event, int, event_enum_vals)
