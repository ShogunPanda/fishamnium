import { Action, ActionPanel, Icon, List } from '@raycast/api'
import { readFile } from 'node:fs/promises'
import { resolve } from 'node:path'
import { JSX, useEffect, useState } from 'react'
import { parse } from 'yaml'

export interface RawBookmark {
  path: string
  name: string
}

export interface Bookmarks {
  name: string
  description: string
  path: string
}

export async function loadBookmarks(): Promise<Bookmarks[]> {
  const file = await readFile(resolve(process.env.HOME!, '.fishamnium.yml'), 'utf8')
  const raw = parse(file)

  const bookmarks: Bookmarks[] = []
  for (const [name, { path, name: description }] of Object.entries(raw.bookmarks as Record<string, RawBookmark>)) {
    bookmarks.push({ name, description, path })
  }

  return bookmarks
}

export function BookmarkResult({ bookmark }: { bookmark: Bookmarks }): JSX.Element {
  const { name, path, description: tooltip } = bookmark
  const absolutePath = path.replace('~', process.env.HOME!)

  return (
    <List.Item
      icon={Icon.Folder}
      title={name}
      subtitle={{ value: bookmark.path, tooltip }}
      actions={
        <ActionPanel>
          <Action.Open
            title="Open in iTerm2"
            icon={Icon.Terminal}
            target={absolutePath}
            application={{ name: 'iTerm2', path: '/Applications/iTerm.app', bundleId: 'com.googlecode.iterm2' }}
          />
          <Action.Open
            title="Open in Visual Studio Code"
            icon={Icon.Code}
            target={absolutePath}
            application={{
              name: 'Visual Studio Code',
              path: '/Applications/Visual Studio Code.app',
              bundleId: 'com.microsoft.VSCode'
            }}
          />
          <Action.CopyToClipboard title="Copy Path" icon={Icon.CopyClipboard} content={path} />
          <Action.CopyToClipboard title="Copy Path (Absolute)" icon={Icon.CopyClipboard} content={absolutePath} />
          <Action.ShowInFinder icon={Icon.Finder} path={absolutePath} />
        </ActionPanel>
      }
    />
  )
}

export default function Command() {
  const [bookmarks, setBookmarks] = useState<Bookmarks[] | undefined>(undefined)
  const [error, setError] = useState<Error | undefined>(undefined)

  useEffect(
    function () {
      async function fetchBookmarks() {
        try {
          setBookmarks(await loadBookmarks())
        } catch (error) {
          setError(error as Error)
        }
      }

      fetchBookmarks()
    },
    [setBookmarks, setError]
  )

  return (
    <List isLoading={!Array.isArray(bookmarks) && typeof error === 'undefined'}>
      {bookmarks?.map(bookmark => <BookmarkResult key={bookmark.path} bookmark={bookmark} />)}
    </List>
  )
}
