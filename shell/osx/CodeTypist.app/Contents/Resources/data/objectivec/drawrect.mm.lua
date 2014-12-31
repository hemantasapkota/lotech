return [=[
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context,[_lineColor CGColor]);
    CGContextSetFillColorWithColor(context, [_progressRemainingColor CGColor]);

    float radius = (rect.size.height / 2) - 2;
    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width -
    2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2,
    rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);

    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2,
    rect.size.height/2, radius);

    CGContextFillPath(context);

    CGContextMoveToPoint(context, 2, rect.size.height/2);
    CGContextAddArcToPoint(context, 2, 2, radius + 2, 2, radius);
    CGContextAddLineToPoint(context, rect.size.width - radius - 2, 2);
    CGContextAddArcToPoint(context, rect.size.width - 2, 2, rect.size.width -
    2, rect.size.height / 2, radius);
    CGContextAddArcToPoint(context, rect.size.width - 2, rect.size.height - 2,
    rect.size.width - radius - 2, rect.size.height - 2, radius);
    CGContextAddLineToPoint(context, radius + 2, rect.size.height - 2);

    CGContextAddArcToPoint(context, 2, rect.size.height - 2, 2,
    rect.size.height/2, radius);

    CGContextStrokePath(context);

    CGContextSetFillColorWithColor(context, [_progressColor CGColor]);
    radius = radius - 2;
    float amount = self.progress * rect.size.width;

    if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
            CGContextMoveToPoint(context, 4, rect.size.height/2);
            CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
            CGContextAddLineToPoint(context, amount, 4);
            CGContextAddLineToPoint(context, amount, radius + 4);

            CGContextMoveToPoint(context, 4, rect.size.height/2);
            CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius +
            4, rect.size.height - 4, radius);
            CGContextAddLineToPoint(context, amount, rect.size.height - 4);
            CGContextAddLineToPoint(context, amount, radius + 4);

            CGContextFillPath(context);
    }

    else if (amount > radius + 4) {
            float x = amount - (rect.size.width - radius - 4);

            CGContextMoveToPoint(context, 4, rect.size.height/2);
            CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
            CGContextAddLineToPoint(context, rect.size.width - radius - 4, 4);
            float angle = -acos(x/radius);
            if (isnan(angle)) angle = 0;
            CGContextAddArc(context, rect.size.width - radius - 4,
            rect.size.height/2, radius, M_PI, angle, 0);
            CGContextAddLineToPoint(context, amount, rect.size.height/2);

            CGContextMoveToPoint(context, 4, rect.size.height/2);

            CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius +
            4, rect.size.height - 4, radius);

            CGContextAddLineToPoint(context, rect.size.width - radius - 4,
            rect.size.height - 4);

            angle = acos(x/radius);
            if (isnan(angle)) angle = 0;

            CGContextAddArc(context, rect.size.width - radius - 4,
            rect.size.height/2, radius, -M_PI, angle, 1);

            CGContextAddLineToPoint(context, amount, rect.size.height/2);

            CGContextFillPath(context);
    }

    else if (amount < radius + 4 && amount > 0) {
            CGContextMoveToPoint(context, 4, rect.size.height/2);
            CGContextAddArcToPoint(context, 4, 4, radius + 4, 4, radius);
            CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);

            CGContextMoveToPoint(context, 4, rect.size.height/2);

            CGContextAddArcToPoint(context, 4, rect.size.height - 4, radius +
            4, rect.size.height - 4, radius);

            CGContextAddLineToPoint(context, radius + 4, rect.size.height/2);

            CGContextFillPath(context);
    }
}
]=]
