import iterm2
import sys

async def main(connection):
  default_profile = await iterm2.PartialProfile.async_get_default(connection)
  print(default_profile.name)

iterm2.run_until_complete(main)