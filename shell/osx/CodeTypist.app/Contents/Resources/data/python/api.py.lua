return [=[
from twisted.web.client import Agent

from treq.client import HTTPClient
from treq._utils import default_pool, default_reactor

def head(url, **kwargs):
    return _client(**kwargs).head(url, **kwargs)

def get(url, headers=None, **kwargs):
    return _client(**kwargs).get(url, headers=headers, **kwargs)

def post(url, data=None, **kwargs):
    return _client(**kwargs).post(url, data=data, **kwargs)


def put(url, data=None, **kwargs):
    return _client(**kwargs).put(url, data=data, **kwargs)

def patch(url, data=None, **kwargs):
    return _client(**kwargs).patch(url, data=data, **kwargs)

def delete(url, **kwargs):
    return _client(**kwargs).delete(url, **kwargs)

def request(method, url, **kwargs):
    return _client(**kwargs).request(method, url, **kwargs)

def _client(*args, **kwargs):
    reactor = default_reactor(kwargs.get('reactor'))
    pool = default_pool(reactor,
                        kwargs.get('pool'),
                        kwargs.get('persistent'))
    agent = Agent(reactor, pool=pool)
    return HTTPClient(agent)
]=]
