# Oauth1

Lightweight OAuth library

## Example

````
url = "https://api.example.com/1.0/endpoint"

headers = to_charlist(OAuth1.generate_authorization_headers("get", url))
{:ok, {{_http, _status, _ok}, _headers, _body}} = OAuth1.request(:get,
      to_charlist(url), [{'Authorization', headers}])

headers = to_charlist(OAuth1.generate_authorization_headers("post", url))
{:ok, {{_http, _status, _ok}, _headers, _body}} = OAuth1.request(:post,
      to_charlist(url), [{'Authorization', headers}])
````
