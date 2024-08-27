import iterm2
import sys

async def main(connection):
  app = await iterm2.async_get_app(connection)
  profiles = await iterm2.PartialProfile.async_query(connection)

  for profile in profiles:
    if profile.name != sys.argv[1]:
      continue

    await profile.async_make_default()

    for window in app.terminal_windows:
      for tab in window.tabs:
        for session in tab.sessions:
          await session.async_set_profile(profile)

iterm2.run_until_complete(main)
