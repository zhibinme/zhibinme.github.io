---
layout: post
title: 'Complete Guide: Integrating Tiptap Rich Text Editor in Next.js'
categories:
- tutorial
tags:
- Next.js
- Tiptap
- pnpm
date: 2026-03-20 09:09 +0800
---
Tiptap is a popular headless rich text editor built on top of ProseMirror, offering rich functionality and flexible customization capabilities. This article will detail how to integrate the Tiptap editor into a Next.js project.

<!-- more -->

## Step 1: Create a Next.js Project with pnpm

First, we need to create a new Next.js project. If you haven't installed pnpm yet, please install it:

```bash
npm install -g pnpm
```

Then use the following command to create a new Next.js project:

```bash
pnpm create next-app@latest tiptap-editor
cd tiptap-editor
```

## Step 2: Install Base Dependencies

Now we need to install the Tiptap-related dependency packages:

```bash
pnpm add @tiptap/react @tiptap/pm @tiptap/starter-kit @tiptap/extension-text-style
```

These packages serve the following purposes:
- `@tiptap/react`: Provides React components and hooks, allowing us to use Tiptap in React applications
- `@tiptap/pm`: The core library of ProseMirror, on which Tiptap is built
- `@tiptap/starter-kit`: Includes commonly used editor extensions (such as headings, lists, quotes, etc.)
- `@tiptap/extension-text-style`: Allows custom text styling

## Step 3: Create Editor Component and Add Styles

### 3.1 Create Editor Component

Create a new file named `app/components/index.tsx`:

```tsx
// 'use client' - Tells Next.js this is a client component, must render in browser
'use client'

// Import Tiptap core packages and extensions
import { TextStyleKit } from '@tiptap/extension-text-style'
import { EditorContent, useEditor } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'

// Configure editor extensions
// - TextStyleKit: Supports custom text styling (font color, etc.)
// - StarterKit: Provides basic editing features (headings, lists, code blocks, quotes, etc.)
const extensions = [TextStyleKit, StarterKit]

const StarterKitEditor = () => {
  // useEditor hook initializes the editor instance
  // immediatelyRender: false - Required for Next.js App Router SSR compatibility
  const editor = useEditor({
    immediatelyRender: false,
    extensions,
    editorProps: {
      attributes: {
        class: 'focus:outline-none',
      },
    },
    // Initial content in HTML format
    content: `
<h2>Hi there,</h2>
<p>this is a <em>basic</em> example of <strong>Tiptap</strong>.</p>
<ul>
  <li>That's a bullet list with one …</li>
  <li>… or two list items.</li>
</ul>
<pre><code class="language-css">body { display: none; }</code></pre>
<blockquote>Wow, that's amazing. Good work, boy! 👏</blockquote>
`,
  })

  // Auto-focus to end of text when clicking the editor content area
  const autoFocus = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (!editor || editor.isFocused) return
    editor.chain().focus('end').run()
  }

  return (
    <EditorContent onClick={autoFocus} className='min-h-52' editor={editor} />
  )
}

export default StarterKitEditor
```

### 3.2 Add Styles

Add the following styles to `app/globals.css`:

```css
@import "tailwindcss";

/* Basic editor styles */
.tiptap {
  :first-child { @apply mt-0; }

  ul, ol { @apply px-4 my-5 mr-4 ml-[0.4rem]; }
  ul { @apply list-disc; }
  ol { @apply list-decimal; }

  h1, h2, h3, h4, h5, h6 { @apply leading-tight mt-10 text-pretty; }
  h1, h2 { @apply mt-14 mb-6; }
  h1 { @apply text-2xl; }
  h2 { @apply text-xl; }
  h3 { @apply text-lg; }
  h4, h5, h6 { @apply text-base; }

  code { @apply px-1 py-0.5 rounded-b-md text-sm font-mono text-gray-900 bg-purple-200; }
  pre { @apply bg-black text-white font-mono rounded-md px-4 py-3 my-6; }
  pre code { @apply bg-inherit text-inherit text-sm p-0; }

  blockquote { @apply border-l-2 border-l-gray-300 my-6 pl-4; }
  hr { @apply border-none border-t border-t-gray-200 my-8; }
}
```

### 3.3 Modify page.tsx

Use our editor in `app/page.tsx`:

```tsx
import Image from "next/image";
import StarterKitEditor from "./components";

export default function Home() {
  return (
    <div className="flex min-h-screen bg-zinc-50 font-sans dark:bg-black">
      <main className="w-full max-w-3xl mx-auto py-32 px-16 bg-white dark:bg-gray-950 sm:items-start">
        <Image className="dark:invert" src="/next.svg" alt="Next.js logo" width={100} height={20} priority />
        <StarterKitEditor />
      </main>
    </div>
  );
}
```

### 3.4 Run and Test

```bash
pnpm dev
```

At this point, you should see a basic Tiptap editor with initial content. Try editing the text to verify the editor is working.

## Step 4: Create and Add Menu Bar

### 4.1 Create MenuBar State Selector

Create `app/components/menuBarState.ts`:

```ts
// State selector for efficient editor state subscription
import type { Editor } from '@tiptap/react'
import type { EditorStateSnapshot } from '@tiptap/react'

/**
 * Why use Selector pattern?
 * Subscribing to editor.state directly causes re-renders on any state change
 * Selector allows precise field specification, avoiding unnecessary performance overhead
 */
export function menuBarStateSelector(ctx: EditorStateSnapshot<Editor>) {
  if (!ctx.editor) {
    return {
      isBold: false, canBold: false, isItalic: false, canItalic: false,
      isStrike: false, canStrike: false, isCode: false, canCode: false,
      canClearMarks: false, isParagraph: false,
      isHeading1: false, isHeading2: false, isHeading3: false,
      isHeading4: false, isHeading5: false, isHeading6: false,
      isBulletList: false, isOrderedList: false,
      isCodeBlock: false, isBlockquote: false,
      canUndo: false, canRedo: false,
    }
  }
  return {
    // Text formatting - isActive checks if currently active, canX checks if can execute
    isBold: ctx.editor.isActive('bold') ?? false,
    canBold: ctx.editor.can().chain().toggleBold().run() ?? false,
    isItalic: ctx.editor.isActive('italic') ?? false,
    canItalic: ctx.editor.can().chain().toggleItalic().run() ?? false,
    isStrike: ctx.editor.isActive('strike') ?? false,
    canStrike: ctx.editor.can().chain().toggleStrike().run() ?? false,
    isCode: ctx.editor.isActive('code') ?? false,
    canCode: ctx.editor.can().chain().toggleCode().run() ?? false,
    canClearMarks: ctx.editor.can().chain().unsetAllMarks().run() ?? false,

    // Block elements
    isParagraph: ctx.editor.isActive('paragraph') ?? false,
    isHeading1: ctx.editor.isActive('heading', { level: 1 }) ?? false,
    isHeading2: ctx.editor.isActive('heading', { level: 2 }) ?? false,
    isHeading3: ctx.editor.isActive('heading', { level: 3 }) ?? false,
    isHeading4: ctx.editor.isActive('heading', { level: 4 }) ?? false,
    isHeading5: ctx.editor.isActive('heading', { level: 5 }) ?? false,
    isHeading6: ctx.editor.isActive('heading', { level: 6 }) ?? false,
    isBulletList: ctx.editor.isActive('bulletList') ?? false,
    isOrderedList: ctx.editor.isActive('orderedList') ?? false,
    isCodeBlock: ctx.editor.isActive('codeBlock') ?? false,
    isBlockquote: ctx.editor.isActive('blockquote') ?? false,

    // History
    canUndo: ctx.editor.can().chain().undo().run() ?? false,
    canRedo: ctx.editor.can().chain().redo().run() ?? false,
  }
}
```

### 4.2 Create MenuBar Component

Create `app/components/MenuBar.tsx`:

```tsx
'use client'

import type { Editor } from '@tiptap/core'
import { useEditorState } from '@tiptap/react'
import { menuBarStateSelector } from './menuBarState'

/**
 * MenuBar Component - Top toolbar for the editor
 * Provides text formatting, block element switching, history operations, etc.
 */
export const MenuBar = ({ editor }: { editor: Editor | null }) => {
  const editorState = useEditorState({
    editor: editor!,
    selector: menuBarStateSelector,
  })

  if (!editor) return <div>Loading...</div>

  // Auto-focus to start of editor when clicking the toolbar
  if (!editor.isFocused) {
    editor.chain().focus('start').run()
  }

  return (
    <div className="control-group">
      <div className="button-group">
        {/* Text formatting buttons */}
        <button onClick={() => editor.chain().focus().toggleMark('bold').run()}
          disabled={!editorState.canBold} className={editorState.isBold ? 'is-active' : ''}>Bold</button>
        <button onClick={() => editor.chain().focus().toggleMark('italic').run()}
          disabled={!editorState.canItalic} className={editorState.isItalic ? 'is-active' : ''}>Italic</button>
        <button onClick={() => editor.chain().focus().toggleMark('strike').run()}
          disabled={!editorState.canStrike} className={editorState.isStrike ? 'is-active' : ''}>Strike</button>
        <button onClick={() => editor.chain().focus().toggleMark('code').run()}
          disabled={!editorState.canCode} className={editorState.isCode ? 'is-active' : ''}>Code</button>

        {/* Clear formatting */}
        <button onClick={() => editor.chain().focus().unsetAllMarks().run()}>Clear marks</button>
        <button onClick={() => editor.chain().focus().clearNodes().run()}>Clear nodes</button>

        {/* Paragraph and headings */}
        <button onClick={() => editor.chain().focus().setParagraph().run()}
          className={editorState.isParagraph ? 'is-active' : ''}>Paragraph</button>
        <button onClick={() => editor.chain().focus().toggleHeading({ level: 1 }).run()}
          className={editorState.isHeading1 ? 'is-active' : ''}>H1</button>
        <button onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()}
          className={editorState.isHeading2 ? 'is-active' : ''}>H2</button>
        <button onClick={() => editor.chain().focus().toggleHeading({ level: 3 }).run()}
          className={editorState.isHeading3 ? 'is-active' : ''}>H3</button>
        <button onClick={() => editor.chain().focus().toggleHeading({ level: 4 }).run()}
          className={editorState.isHeading4 ? 'is-active' : ''}>H4</button>
        <button onClick={() => editor.chain().focus().toggleHeading({ level: 5 }).run()}
          className={editorState.isHeading5 ? 'is-active' : ''}>H5</button>
        <button onClick={() => editor.chain().focus().toggleHeading({ level: 6 }).run()}
          className={editorState.isHeading6 ? 'is-active' : ''}>H6</button>

        {/* Lists and block elements */}
        <button onClick={() => editor.chain().focus().toggleBulletList().run()}
          className={editorState.isBulletList ? 'is-active' : ''}>Bullet list</button>
        <button onClick={() => editor.chain().focus().toggleOrderedList().run()}
          className={editorState.isOrderedList ? 'is-active' : ''}>Ordered list</button>
        <button onClick={() => editor.chain().focus().toggleCodeBlock().run()}
          className={editorState.isCodeBlock ? 'is-active' : ''}>Code block</button>
        <button onClick={() => editor.chain().focus().toggleBlockquote().run()}
          className={editorState.isBlockquote ? 'is-active' : ''}>Blockquote</button>

        {/* Others */}
        <button onClick={() => editor.chain().focus().setHorizontalRule().run()}>HR</button>
        <button onClick={() => editor.chain().focus().setHardBreak().run()}>Break</button>

        {/* History */}
        <button onClick={() => editor.chain().focus().undo().run()} disabled={!editorState.canUndo}>Undo</button>
        <button onClick={() => editor.chain().focus().redo().run()} disabled={!editorState.canRedo}>Redo</button>
      </div>
    </div>
  )
}
```

### 4.3 Add MenuBar Styles

Add to `app/globals.css`:

```css
/* MenuBar buttons */
.button-group { @apply flex gap-1 my-4 flex-wrap; }
.button-group button { @apply bg-gray-100 border-gray-200 rounded-md cursor-pointer h-8 py-1 px-2 transition-all; }
.button-group button:hover:not(:disabled) { @apply bg-gray-200; }
.button-group button:disabled { @apply cursor-not-allowed opacity-60; }
.button-group button.is-active { @apply bg-purple-900 border-purple-900 text-white; }
.button-group button.is-active:hover:not(:disabled) { @apply bg-purple-800; }
```

### 4.4 Update Editor Component

Update `app/components/index.tsx` to include MenuBar:

```tsx
// ... existing imports ...
import { MenuBar } from './MenuBar'  // New

const StarterKitEditor = () => {
  // ... useEditor hook (no changes) ...

  return (
    <>
      <MenuBar editor={editor} />  {/* New */}
      <EditorContent onClick={autoFocus} className='min-h-52' editor={editor} />
    </>
  )
}
```

Now refresh the page, you should see the MenuBar above the editor with formatting buttons.

## Step 5: Add Bubble Menu

### 5.1 Install Bubble Menu Dependency

```bash
pnpm add @tiptap/react @tiptap/extension-bubble-menu
```

### 5.2 Update Editor Component

Update `app/components/index.tsx` to include BubbleMenu:

```tsx
// ... existing imports ...
import { useEditorState } from '@tiptap/react'  // New
import { BubbleMenu } from '@tiptap/react/menus'  // New
import { menuBarStateSelector } from './menuBarState'  // New

const StarterKitEditor = () => {
  // ... useEditor hook (no changes) ...

  // New: Subscribe to editor state for BubbleMenu
  const editorState = useEditorState({
    editor: editor!,
    selector: menuBarStateSelector,
  })

  return (
    <>
      <MenuBar editor={editor} />

      {/* New: BubbleMenu - appears when text is selected */}
      {editor && (
        <BubbleMenu editor={editor} options={
          { placement: 'bottom', offset: 8, flip: true }
          }>
          <div className="bubble-menu">
            <button onClick={() => editor.chain().focus().toggleBold().run()}
              className={editorState.isBold ? 'is-active' : ''}>Bold</button>
            <button onClick={() => editor.chain().focus().toggleItalic().run()}
              className={editorState.isItalic ? 'is-active' : ''}>Italic</button>
            <button onClick={() => editor.chain().focus().toggleStrike().run()}
              className={editorState.isStrike ? 'is-active' : ''}>Strike</button>
          </div>
        </BubbleMenu>
      )}

      <EditorContent onClick={autoFocus} className='min-h-52' editor={editor} />
    </>
  )
}
```

### 5.3 Add BubbleMenu Styles

Add to `app/globals.css`:

```css
/* Bubble menu styles */
.bubble-menu { @apply bg-white border-gray-100 rounded-lg shadow-md flex text-sm font-bold divide-x divide-gray-200; }
.bubble-menu button { @apply p-1; }
.bubble-menu button:first-child { @apply rounded-l-lg; }
.bubble-menu button:last-child { @apply rounded-r-lg; }
.bubble-menu button:hover { @apply bg-gray-300; }
.bubble-menu button.is-active { @apply bg-purple-900 text-white; }
.bubble-menu button.is-active:hover { @apply bg-purple-800; }
```

Now select some text in the editor, and you should see the BubbleMenu appear above your selection.

## Summary of Key Points

### 1. Project Creation
- Use `pnpm` as the package manager
- Use `pnpm create next-app@latest` to scaffold the project

### 2. Dependency Installation
- Core: `@tiptap/react`, `@tiptap/starter-kit`
- Text styling: `TextStyleKit` from `@tiptap/extension-text-style`
- Bubble menu: `@tiptap/react/menus`

### 3. Editor Creation
- `useEditor` hook initializes the editor
- `immediatelyRender: false` is required for Next.js App Router SSR compatibility
- `EditorContent` component renders the editing area

### 4. Menu Bar
- `menuBarStateSelector` enables efficient state subscription (avoids unnecessary re-renders)
- `useEditorState` with selector pattern: only re-renders when relevant state changes
- `editor.isActive()` checks current formatting state
- `editor.can().command()` checks if command is executable
- `editor.chain().focus().command().run()` executes a command

### 5. Bubble Menu
- Appears when text is selected
- Uses `useEditorState` to get active states for buttons

## Running the Project

```bash
pnpm dev
```

Visit http://localhost:3000 to see the complete Tiptap editor with menu bar and bubble menu.

## Conclusion

Through these five steps, we integrated Tiptap into Next.js with menu bar and bubble menu. Tiptap's modular design allows flexible feature addition/removal for various rich text editing needs.
