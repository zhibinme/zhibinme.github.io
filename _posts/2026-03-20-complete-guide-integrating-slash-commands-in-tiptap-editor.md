---
layout: post
title: 'Complete Guide: Integrating Slash Commands in Tiptap Editor'
category: tutorial
tags:
- Next.js
- Tiptap
- slash commands
- pnpm
- rich text editor
date: 2026-03-20 09:27 +0800
---
Slash Commands allow users to trigger actions by typing `/` in the editor, displaying a list of available commands. This article will detail how to integrate Slash Commands into a Tiptap editor in Next.js.

> This tutorial is based on the official Tiptap experiment [Slash Commands](https://tiptap.dev/docs/examples/experiments/slash-commands), originally a Vue implementation ported to React.

<!--more-->

## Step 1: Create a Next.js Project with pnpm

First, create a new Next.js project:

```bash
npm install -g pnpm
pnpm create next-app@latest slash-commands
cd slash-commands
```

## Step 2: Install Base Dependencies

Install Tiptap and the suggestion plugin:

```bash
pnpm add @tiptap/react @tiptap/pm @tiptap/starter-kit @tiptap/suggestion @floating-ui/dom
```

These packages serve the following purposes:
- `@tiptap/react`: React components and hooks for Tiptap
- `@tiptap/pm`: Core ProseMirror library
- `@tiptap/starter-kit`: Basic editor extensions
- `@tiptap/suggestion`: Plugin for slash commands and mentions
- `@floating-ui/dom`: Positioning library for floating elements

## Step 3: Create Basic Editor Component

### 3.1 Create Editor Component

Create `app/react/Editor.tsx`:

```tsx
'use client'

import { useEditor, EditorContent } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'

const Editor = () => {
  const editor = useEditor({
    extensions: [StarterKit],
    content: '<p>Hello World!</p>',
    editorProps: {
      attributes: {
        class: 'focus:outline-none',
      },
    },
    immediatelyRender: false,
  })

  return editor && <EditorContent editor={editor} />
}

export default Editor
```

### 3.2 Add Styles

Add to `app/globals.css`:

```css
@import "tailwindcss";

.tiptap {
  :first-child { @apply mt-0; }
  ul, ol { @apply px-4 my-5 mr-4 ml-[0.4rem]; }
  ul { @apply list-disc; }
  ol { @apply list-decimal; }
  h1, h2, h3, h4, h5, h6 { @apply leading-tight mt-10 text-pretty; }
  code { @apply px-1 py-0.5 rounded text-sm font-mono text-gray-900 bg-purple-200; }
  pre { @apply bg-black text-white font-mono rounded-md px-4 py-3 my-6; }
  pre code { @apply bg-inherit text-inherit text-sm p-0; }
  blockquote { @apply border-l-2 border-l-gray-300 my-6 pl-4; }
}
```

### 3.3 Modify page.tsx

Update `app/page.tsx`:

```tsx
import Image from "next/image"
import Editor from "./react/Editor"

export default function Home() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 font-sans dark:bg-black">
      <main className="w-full max-w-3xl mx-auto py-32 px-16 bg-white dark:bg-black sm:items-start">
        <Image className="dark:invert" src="/next.svg" alt="Next.js logo" width={100} height={20} priority />
        <Editor />
      </main>
    </div>
  )
}
```

### 3.4 Test Basic Editor

```bash
pnpm dev
```

You should see a basic Tiptap editor. Now we'll add Slash Commands functionality.

## Step 4: Create Slash Commands Extension

### 4.1 Create Commands Extension

Create `app/react/commands.ts`:

```ts
// Commands Extension - Integrates the Suggestion plugin with Tiptap
import { Extension, Editor, Range } from '@tiptap/core'
import Suggestion from '@tiptap/suggestion'

// Command item interface
interface CommandItem {
  title: string
  command: (props: { editor: Editor; range: Range }) => void
}

export default Extension.create({
  name: 'slash-commands',

  addOptions() {
    return {
      suggestion: {
        char: '/',  // Trigger character
        command: ({ editor, range, props }: { editor: Editor; range: Range; props: CommandItem }) => {
          props.command({ editor, range })
        },
      },
    }
  },

  addProseMirrorPlugins() {
    return [
      Suggestion({
        editor: this.editor,
        ...this.options.suggestion,
      }),
    ]
  },
})
```

### 4.2 Create Suggestion Configuration

Create `app/react/suggestion.ts`:

```ts
// Suggestion configuration - Handles slash command suggestions
import { computePosition, flip, shift } from '@floating-ui/dom'
import { posToDOMRect, Editor, Range } from '@tiptap/core'
import { ReactRenderer } from '@tiptap/react'
import { SuggestionList, SuggestionListRef } from './SuggestionList'

// Update suggestion list position using Floating UI
const updatePosition = (editor: Editor, element: HTMLElement) => {
  const virtualElement = {
    getBoundingClientRect: () => posToDOMRect(editor.view, editor.state.selection.from, editor.state.selection.to),
  }

  computePosition(virtualElement, element, {
    placement: 'bottom-start',
    strategy: 'absolute',
    middleware: [shift(), flip()],
  }).then(({ x, y, strategy }) => {
    element.style.width = 'max-content'
    element.style.position = strategy
    element.style.left = `${x}px`
    element.style.top = `${y}px`
  })
}

export const suggestion = {
  // Filter commands based on query
  items: ({ query }: { query: string }) => {
    return [
      {
        title: 'Heading 1',
        command: ({ editor, range }: { editor: Editor; range: Range }) => {
          editor.chain().focus().deleteRange(range).setNode('heading', { level: 1 }).run()
        },
      },
      {
        title: 'Heading 2',
        command: ({ editor, range }: { editor: Editor; range: Range }) => {
          editor.chain().focus().deleteRange(range).setNode('heading', { level: 2 }).run()
        },
      },
      {
        title: 'Bold',
        command: ({ editor, range }: { editor: Editor; range: Range }) => {
          editor.chain().focus().deleteRange(range).setMark('bold').run()
        },
      },
      {
        title: 'Italic',
        command: ({ editor, range }: { editor: Editor; range: Range }) => {
          editor.chain().focus().deleteRange(range).setMark('italic').run()
        },
      },
    ]
      .filter(item => item.title.toLowerCase().startsWith(query.toLowerCase()))
      .slice(0, 10)
  },

  // Render suggestion list
  render: () => {
    let reactRenderer: ReactRenderer | null = null

    return {
      onStart: (props: { editor: Editor; clientRect?: DOMRect }) => {
        reactRenderer = new ReactRenderer(SuggestionList, {
          props,
          editor: props.editor,
        })

        const element = reactRenderer.element
        element.style.position = 'absolute'

        if (!props.clientRect) return

        document.body.appendChild(element)
        updatePosition(props.editor, element)
      },

      onUpdate: (props: { editor: Editor; clientRect?: DOMRect }) => {
        reactRenderer?.updateProps(props)
        if (!props.clientRect) return
        updatePosition(props.editor, reactRenderer?.element as HTMLElement)
      },

      onKeyDown: (props: { event: KeyboardEvent }) => {
        if (props.event.key === 'Escape') {
          reactRenderer?.destroy()
          const dropdown = document.querySelector('.dropdown-menu')
          if (dropdown) dropdown.remove()
          return true
        }
        return (reactRenderer?.ref as SuggestionListRef | null)?.onKeyDown(props) || false
      },

      onExit: () => {
        reactRenderer?.destroy()
        reactRenderer = null
        const dropdown = document.querySelector('.dropdown-menu')
        if (dropdown) dropdown.remove()
      },
    }
  },
}
```

### 4.3 Create SuggestionList Component

Create `app/react/SuggestionList.tsx`:

```tsx
// SuggestionList Component - Displays command suggestions
import { forwardRef, useImperativeHandle, useState, useEffect } from 'react'
import { Editor, Range } from '@tiptap/core'

// Command item interface
export interface CommandItem {
  title: string
  command: (props: { editor: Editor; range: Range }) => void
}

// Expose onKeyDown method via ref
export interface SuggestionListRef {
  onKeyDown: (props: { event: KeyboardEvent }) => boolean
}

interface SuggestionListProps {
  items: CommandItem[]
  command: (item: CommandItem) => void
}

export const SuggestionList = forwardRef<SuggestionListRef, SuggestionListProps>(
  ({ items, command }, ref) => {
    const [selectedIndex, setSelectedIndex] = useState(0)

    // Reset selection when items change
    useEffect(() => {
      setSelectedIndex(0)
    }, [items])

    const handleKeyDown = ({ event }: { event: KeyboardEvent }) => {
      if (event.key === 'ArrowUp') {
        setSelectedIndex(prev => (prev + items.length - 1) % items.length)
        return true
      }
      if (event.key === 'ArrowDown') {
        setSelectedIndex(prev => (prev + 1) % items.length)
        return true
      }
      if (event.key === 'Enter') {
        if (items[selectedIndex]) command(items[selectedIndex])
        return true
      }
      return false
    }

    useImperativeHandle(ref, () => ({
      onKeyDown: handleKeyDown,
    }))

    return (
      <div className="dropdown-menu">
        {items.length > 0 ? (
          items.map((item, index) => (
            <button
              key={item.title}
              className={index === selectedIndex ? 'is-selected' : ''}
              onClick={() => command(item)}
            >
              {item.title}
            </button>
          ))
        ) : (
          <div className="text-gray-500">No result</div>
        )}
      </div>
    )
  }
)

SuggestionList.displayName = 'SuggestionList'
```

### 4.4 Add SuggestionList Styles

Add to `app/globals.css`:

```css
/* Dropdown menu */
.dropdown-menu {
  @apply bg-white border border-gray-200 rounded-xl shadow-md flex flex-col gap-0.5 overflow-auto p-1 absolute;
}

.dropdown-menu button {
  @apply bg-transparent border-none rounded-md cursor-pointer px-1.5 py-1 text-left;
}

.dropdown-menu button.is-selected {
  @apply bg-gray-100;
}
```

### 4.5 Update Editor Component

Update `app/react/Editor.tsx` to include Commands:

```tsx
// ... existing imports ...
import Commands from './commands'
import { suggestion } from './suggestion'

const Editor = () => {
  const editor = useEditor({
    extensions: [
      StarterKit,
      Commands.configure({ suggestion }),  // Add slash commands
    ],
    content: '<p>Type / to see commands...</p>',
    // ... rest of config
  })

  return editor && <EditorContent editor={editor} />
}
```

## Summary of Key Points

### 1. Project Setup
- Use `pnpm` as package manager
- Install `@tiptap/suggestion` for slash commands
- Install `@floating-ui/dom` for positioning

### 2. Commands Extension (commands.ts)
- Creates a Tiptap Extension named 'slash-commands'
- Integrates `@tiptap/suggestion` plugin
- Configures trigger character (`/`) and command handler

### 3. Suggestion Configuration (suggestion.ts)
- `items`: Filters commands based on user input query
- `render`: Returns lifecycle methods for the suggestion popup
  - `onStart`: Create ReactRenderer when slash is typed
  - `onUpdate`: Update position and props when query changes
  - `onKeyDown`: Handle keyboard navigation (Arrow keys, Enter, Escape)
  - `onExit`: Cleanup when suggestion closes
- Uses Floating UI for positioning

### 4. SuggestionList Component
- React component rendered inside the suggestion popup
- `forwardRef` exposes `onKeyDown` for keyboard handling
- Arrow keys navigate, Enter selects, Escape closes
- `useImperativeHandle` exposes internal keyboard handler

### 5. Editor Integration
- Import Commands extension and suggestion config
- Use `Commands.configure({ suggestion })` to combine them
- Register in extensions array alongside StarterKit

## Running the Project

```bash
pnpm dev
```

Type `/` in the editor to see the command suggestions. Use arrow keys to navigate and Enter to select.

## Conclusion

Through these steps, we implemented Slash Commands in Tiptap. The key concepts:
- Tiptap Extension wraps the Suggestion plugin
- Suggestion config defines `items` and `render` lifecycle
- ReactRenderer renders React components inside ProseMirror
- `forwardRef` enables keyboard handling from suggestion config

## Extending Commands

To add new commands, simply add items to the `items` array in `suggestion.ts`:

```ts
{
  title: 'Your Command',
  command: ({ editor, range }) => {
    // Your command logic
    editor.chain().focus().deleteRange(range).run()
  },
}
```
