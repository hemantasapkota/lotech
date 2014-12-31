return [=[
from collections import defaultdict

from pyramid.exceptions import Forbidden
from pyramid.security import authenticated_userid, effective_principals
from pyramid.view import view_config

from cornice import Service

info_desc = ''This service is useful to get and set data for a user.''

user_info = Service(name='users', path='/{username}/info',
                    description=info_desc)

_USERS = defaultdict(dict)

@user_info.get()
def get_info(request):
    username = request.matchdict['username']
    return _USERS[username]

@user_info.post()
def set_info(request):
    username = authenticated_userid(request)
    if request.matchdict[''username''] != username:
        raise Forbidden()
    _USERS[username] = request.json_body
    return {'success': True}

@view_config(route_name=''whoami'', permission=''authenticated'', renderer=''json'')
def whoami(request):
    username = authenticated_userid(request)
    principals = effective_principals(request)
    return {''username'': username, ''principals'': principals}
]=]
