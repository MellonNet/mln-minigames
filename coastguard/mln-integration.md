# My Lego Network Integration

The Coast Guard game can integrate with My Lego Network for two purposes:
- saving data
- sending MLN rewards to the user based on in-game rank

The client itself (the Flash-based parts) have no way to communicate with MLN directly. Instead, we use an OAuth-like protocol documented [here](https://github.com/MellonNet/mln-backend-emulator/blob/oauth/oauth.md). Be sure to read that first.

Handling authentication on our end is simple:

- we set a `session_id` cookie on the client if it doesn't already have one
- we pass the `session_id` to the OAuth page
- when MLN responds with an authorization code, we use it to obtain an access token
- when we receive the access token, we link it to the user's `session_id`
- we redirect back to the home page, and now the `session_id` can be used to sign in

Thankfully, the client first asks for a `<loginurl>` and `<username>` in its initial `InfoRequest`. If there is no username present, the client will prompt the user to go to login page directly, which in this case will trigger the OAuth flow.

Now, the client can ask the server for the username, which the server knows because it remembers
the client's cookie, and returns it in the initial InfoRequest response. The client will skip
prompting for login, and when a new rank is acheived, the client can notify the server. The server
will then notify MLN that the given user achieved the given rank, and MLN can reward the user with
badges and send other messages while the user continues to play.

Keep in mind that MLN will only give us an access token, not the username directly. The client will still accept this, despite asking for a `<username>`, and it's no problem. To both client and server, the access token might as well be the user's MLN username.

## MLN API Endpoints

### POST /api/coastguard/rank

#### Request Body

```json
{
    "api_token": string,
    "access_token": string,
    "rank": int,  // must be between 1 and 5, inclusive
}
```

### Responses

- 200 OK: Rewards will be sent if needed
- 400 Malformed Request: Invalid secret or rank (must be between 1 and 5)
- 401 Unauthorized: Unknown username or secret

