import "utils.dart";

final helpCommand = ChatCommand(
  "help",
  "Let me tell you what I can do!",
  _help,
);

const helpText = """
## Welcome Friend!

Hi! Hi! I'm the MellonBot, your first friend in the MellonNet Discord. If you need anything to do with MellonNet, I'm your bot! Bot! I can fetch information about users, items, and modules, and also let you know when you get new messages or friends by sending you a direct message!

**Basic Commands (no login required)**
- `/random-user`: I'll find you a random user at any rank -- a great way to make friends!
- `/who-is`: I'll tell you information based on an MLN username or Discord user
- `/who-has`: I'll find a random user with the module you're looking for
- `/what-is`: I'll explain any item or module (if you use `/explain` I'll post publicly)
- `/help`: Show this help message

**Did you know?** When a command asks for a user, you can either give me their MellonNet username or `@mention` their Discord username. If they're also using the MellonBot, I can find their MellonNet profiles automatically!

**Advanced** (unlocked by using `/login`)
- When you rank up or get a new badge, I'll post about it in https://discord.com/channels/394573245380034573/1415539562381447241
- I'll give you a role based on your MLN rank (use `/mini-rank` to get another role)
- Use `/nickname` to add your MLN username to your Discord profile (only on our server)
- Use `/befriend`, `/unfriend`, `/block`, and `/unblock` to manage friends
- Use `/mailbox` to see your last three messages
- Use `/subscribe` and `/unsubscribe` to get notified about new friends or messages

You can unlink your account at any time by using `/logout`

Most of my messages are shown privately, only to you, and there's a button to dismiss it. If you subscribe to something, I'll send you a DM. If you want to delete my messages, just use the :x: reaction and I'll get rid of it.

-# I'm being improved all the time, and new commands are coming soon!
""";

Future<void> _help(ChatContext context) => context.respondText(helpText);

const welcomeText = """
## Welcome to the Network, Friend!

Hi! Hi! I'm the MellonBot, your first friend in the MellonNet Discord. If you need anything to do with MellonNet, I'm your bot! Bot! I can fetch information about users, items, and modules, and also let you know when you get new messages or friends by sending you a direct message!

For more information on MellonNet and My Lego Network, visit our website [here](https://mellonnet.com). Before you can play, you'll need to get yourself a Flaash-compatible browser. Click [here](https://mellonnet.com/setup) to get started. When you're all settled in, come back here and start some commands:
- `/who-is`: I'll tell you information based on an MLN username or Discord user
- `/who-has`: I'll find a random user with the module you're looking for
- `/what-is`: I'll explain how to get and use any item or module
- `/random-user` I'll find you a random user at any rank -- a great way to make new friends!
- `/help` to see what else I can do

If you share your MLN account with me by clicking below, you'll unlock even more features:
- I can send you a DM when you get a new friend request or message
- When you rank up or get a new badge, I'll post about it in https://discord.com/channels/394573245380034573/1415539562381447241
- I'll give you a role based on your rank and mini-rank
- I'll show your MLN and Discord usernames when responding to `/who-is` requests
- Whenever I give information about a user, I'll include a button to send a friend request
- More commands linked to your account like `/befriend`, `/mailbox`, and `/nickname`

See you around the Network, friend!
""";
