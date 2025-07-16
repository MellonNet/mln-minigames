# The Robot Chronicles

A server to provide the Flash files and My Lego Network integration for The Robot Chronicles, an old Flash-based game by LEGO®.

> [!Note]
> LEGO® is a trademark of the LEGO Group of companies which does not sponsor, authorize or endorse this site, and is not liable for any safety issues in relation to its operation.
>
> No profit is being derived from this project, it is simply a restoration for restoration's sake, to enable players to play the games they grew up with.
>
> The operation of this project follows existing precedents and guidelines set by the LEGO Group (and other organizations) in relation to fan projects and abandonware (including the existance of other such projects). Should any party with claim to the intillectual property used in this project have issue with its operation, please contact us immediately and we will take action as soon as possible to resolve, or ultimately remove this project if necessary.

## Status

### Implemented

- Full gameplay and progression
- Sign in with My Lego Network for rewards in MLN
- Some QoL optimizations for modern hardware

### Not implemented

- MLN being able to drop items in-game. Not sure what this is about or how to recreate

## Running the server

### Setup

This server uses [Dart](https://dart.dev/get-dart), so be sure to have that installed. Before running, add the following file:

```dart
// lib/src/secrets.dart

// If you are't trying to set up MLN integration (see below), use an empty string.
const apiToken = "YOUR MLN API TOKEN";
```

Now run the server with `dart run`.

#### MLN integration

This server can integrate with an OAuth-enabled My Lego Network server. You'll need to register your Robot Chronicles server with the MLN server. See the "Setup" section of [the MLN OAuth docs](https://github.com/MellonNet/mln-backend-emulator/blob/oauth/oauth.md#setup) for details.

When the "Collect your MLN Reward" button appears in-game, users can press it to send the following payload to this server:

```js
// POST /undefined/ExecuteAwardgiver
{
  "awardCategory": string,
  "localeId": string,
  "awardCode": string,
}
```

The `undefined` part in the URL can be adjusted but is completely arbitrary, so has been left alone. All possible values are spelled out in `config.xml`. Specifically, `awardCategory` and `localeId` only have one possible option, but `awardCode` can range from `Cross1` through `Cross7`. These values are sent as a url-encoded form and the values are XOR-encrypted. The key has been extracted from the original Flash code.

Since the payload does not contain any information about the user, the static server adds a `session_id` cookie to the browser when the Flash files are first requested. This way, the POST request can then be associated to a user session.

 If there is no session, the server is to return XML like the following:

```xml
<result status="200">
  <message
    title="Sign into My Lego Network"
    text="Some text to show in the sign-in box"
    buttonText="Sign in"
    link=LOGIN_LINK
  />
</result>
```

This response must also be encrypted with the same key. `LOGIN_LINK` should be replaced by a well-formed login URL according to the [MLN OAuth docs](https://github.com/MellonNet/mln-backend-emulator/blob/oauth/oauth.md#setup). This will spawn a pop-up dialog in-game with the provided fields, which will forward the user to the link. Since login is only requested after passing a milestone in-game, the server must temporarily remember the user's achievement until the OAuth flow is complete, then send the correct request to MLN and redirect the user back to the game.

If the user's session is already associated with an MLN account, a simple 200 response will do.

To send awards in MLN, make the following POST request to MLN's servers with a JSON body:

```js
// POST /api/robot-chronicles/award
{
  "api_token": API_TOKEN,
  "access_token": ACCESS_TOKEN,
  "award": int,  // 1-5, inclusive
}
```

Where `API_TOKEN` and `ACCESS_TOKEN` are replaced with their appropriate values. MLN will then send the appropriate message and awards to the user's mailbox. The award comes from the number at the end of the original `awardCode` form data, and corresponds to:

1. Crane Quest
2. Speed Inferno Challenge
3. Infestation
4. Towing the Line
5. The Fall of the Robot

This was reverse-engineered by inspecting the Flash code. Some relevant ActionScript snippets have been categorized in the `actionscript/` directory

There seems to have been a way to get the client to load arbitrary rewards from MLN. Just add the following to your response:
```xml
<result status="200">
  <message ...>
  <items>
    <item thumbnail="flash_file.swf"/>
    <!-- More items... -->
  </items>
</result>
```

This will cause the client to download and execute any SWF file you provide. However, the original files were not archived and so this feature is not implemented.

### Project Structure

- `actionscript/`: Relevant or interesting parts of the original Flash/ActionScript code.
  - For convenience, `actionscript/scripts` has been added to the `.gitignore` so you can dump all the code and explore it in an IDE.
- `bin/`: Contains the main entrypoint for the server, which sets up the different routes.
- `lib/`: Contains all the Dart code to handle requests, authentication, and MLN integration.
- `static/`: Contains all the original Flash files needed to run the game, served as-is by the webserver.

## Modifications to the Flash source

The files in `static` were taken mostly as-is from archives, with the following changes (made using the JPEXS Free Flash Decompiler):

1. `TheRobotChronicles.swf`, scripts/frame 201, DoAction [18]: Disable tracking
```diff
kv_v.lc = function() {
- kv_v.l_mcl.loadClip(_loc1_,kv_v.t_mc);
+ // kv_v.l_mcl.loadClip(_loc1_,kv_v.t_mc);
```

2. `scripts/frame_201`, `DoAction [42]`: Lowered the max speed
```diff
this.setMechanics = function(speed, acceleration, grip, steering, offroad) {
-   this.speedMax = (speed + 1) * 1.25;
+   this.speedMax = (speed + 1) * 1.25 * 0.75;
```

3. `scripts/frame_201`, `DoAction [42]`: Lowered the skid effect
```diff
if(this.control.LEFT) {
-  this.roll -= 2;
+  this.roll -= 1;
```
```diff
else if(this.control.RIGHT) {
-   this.roll += 2;
+   this.roll += 1;
```

4. `scripts/frame_201`, `DoAction [23]`: Enabled `test` as a cheat code
```diff
- if(code == "hooloovoo" && dialogue("CHT_allowTM") == "TRUE")
+ if((code == "hooloovoo" || code == "test") && dialogue("CHT_allowTM") == "TRUE")
```

5. `scripts/frame_201`, `DoAction [47]`: Fixed FPS reporting (only visible in test mode)
```diff
this.handle = function() {
+   this.fpsCounter++

...

this.calcFPS = function() {  // replace entire body with below
+   var _loc2_ = getTimer();
+   if(!isNaN(this.nextTimeFps) && _loc2_ < this.nextTimeFps) {
+      return this.fps;
+   }
+   this.nextTimeFps = _loc2_ + 1000;
+   var _loc3_ = this.fpsCounter;
+   this.fpsCounter = 0;
+   this.frameDuration = this.currentTime - this.previousTime;
+   this.previousTime = this.currentTime;
+   this.currentTime = getTimer();
+   return _loc3_;
}
```

6. `scripts/frame_201`, `DoAction [47]`: Lock the framerate (doesn't seem to matter much)
```diff
this.handle = function() {
+   this.currentTime2 = getTimer();
+   this.frameInterval = 1000 / this.framesPerSecond;
+   if (!isNaN(this.nextTime2) && this.currentTime2 < this.nextTime2) {
+     return undefined;
+   }
+   this.nextTime2 = this.currentTime2 + this.frameInterval;
    this.fpsCounter++;
```
