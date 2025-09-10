import "utils.dart";

final helpCommand = ChatCommand(
  "help",
  "Let me tell you what I can do!",
  _help,
);

const helpText = """
## Welcome Friend!

Hi! Hi! I'm the MellonBot, your first friend in the MellonNet Discord. If you need anything to do with MellonNet, I'm your bot! Bot! I can fetch information about users, items, and modules, and also let you know when you get new messages or friends by sending you a direct message!

Here's a bit of what I can do:

**Users**
- `/befriend USER` and `/unfriend USER`
- `/block USER` and `/unblock USER`
- `/who-is USER`
- `/random RANK`

Did you know? When a command asks for a user, you can either give me their MellonNet username or `@mention` their Discord username. If they're also using the MellonBot, I can find their MellonNet profiles automatically!

**Modules and items**
- `/what-is MODULE_OR_ITEM` (if you use `/explain` I'll respond in the chat!)

**Misc**
- `/login` and `/logout`
- `/subscribe mail` and `/unsubscribe mail`
- `/help`

Most of my messages are shown privately, only to you, and there's a button to dismiss it. If I ever send a public message that you want to delete, just use the :x: reaction and I'll get rid of it.

-# I'm being improved all the time, and new commands are coming soon!
""";

Future<void> _help(ChatContext context) =>
  context.respondText(helpText);
