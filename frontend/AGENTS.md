# AGENTS.md - Frontend (Next.js)

## Package Identity
- **Purpose**: Server-rendered React UI with API integration
- **Framework**: Next.js 14 (App Router) + React 18 + TypeScript
- **Package Manager**: bun
- **Styling**: Tailwind CSS + shadcn/ui patterns

## Setup & Run
```bash
# Install dependencies
cd frontend && bun install

# Run dev server (from project root)
make dev-frontend
# Or directly:
bun run dev

# Build production
bun run build

# Run tests (Playwright)
bun run test

# Lint & typecheck
bun run lint
bun run typecheck
```

## Patterns & Conventions

### File Organization
```
src/
├── app/              # Next.js App Router
│   ├── layout.tsx    # Root layout
│   ├── page.tsx      # Home page
│   ├── providers.tsx # Client providers (QueryClient)
│   └── globals.css   # Global styles + CSS variables
├── components/       # React components
│   └── ui/           # Base UI components (shadcn pattern)
│       ├── button.tsx
│       └── input.tsx
└── lib/              # Utilities
    ├── api.ts        # API client wrapper
    └── utils.ts      # cn() helper, etc.
```

### Patterns to Follow
- ✅ **Pages**: Copy pattern from `src/app/page.tsx`
- ✅ **Layouts**: Copy pattern from `src/app/layout.tsx`
- ✅ **Components**: Copy pattern from `src/components/ui/button.tsx`
- ✅ **API calls**: Use `api` from `src/lib/api.ts`
- ✅ **Styling**: Use `cn()` from `src/lib/utils.ts` for conditional classes

### Naming Conventions
- **Files**: `kebab-case.tsx` for pages, `PascalCase.tsx` for components
- **Components**: `PascalCase` exports
- **Hooks**: `use` prefix (e.g., `useUser`)
- **Utils**: `camelCase`

### Component Patterns
```tsx
// ✅ DO: Functional component with TypeScript
export function Button({ children, variant = "default" }: ButtonProps) {
  return <button className={cn(baseStyles, variants[variant])}>{children}</button>
}

// ❌ DON'T: Class components
// ❌ DON'T: Inline styles
// ❌ DON'T: Hardcoded colors (use CSS variables)
```

### State Management
- **Server state**: TanStack Query (`@tanstack/react-query`)
- **Client state**: React Context (see `src/app/providers.tsx`)
- **Forms**: React Hook Form + Zod validation

## Touch Points / Key Files
```
src/app/layout.tsx      # Root layout, metadata, fonts
src/app/providers.tsx   # QueryClientProvider setup
src/app/globals.css     # CSS variables (colors, radius)
src/lib/api.ts          # Fetch wrapper with auth
src/lib/utils.ts        # cn() helper
tailwind.config.ts      # Theme customization
next.config.js          # Next.js config
```

## JIT Index Hints
```bash
# Find all pages
find src/app -name "page.tsx"

# Find all components
rg -n "export (function|const) \w+" src/components/

# Find hooks usage
rg -n "use[A-Z]\w+\(" src/

# Find API calls
rg -n "api\.(get|post|put|delete)" src/

# Find Tailwind classes
rg -n "className=" src/

# Find environment variables
rg -n "process\.env\." src/
rg -n "NEXT_PUBLIC_" src/
```

## Common Gotchas
- Client components need `"use client"` directive at top
- Environment vars for browser need `NEXT_PUBLIC_` prefix
- Use `@/` import alias for absolute paths
- API URL comes from `NEXT_PUBLIC_API_URL` environment variable
- Images need `next/image` component for optimization

## Testing (Playwright)
```bash
# Run all e2e tests
bun run test

# Run with UI
bun run test:ui

# Test config in playwright.config.ts
```

## Pre-PR Checks
```bash
cd frontend && bun run lint && bun run typecheck && bun run build
```

## Bug Fix Protocol (MANDATORY)
1. **Reproduce**: Run failing test first
2. **Fix**: Implement solution  
3. **Verify**: Run `bun run test` (Playwright) and **paste output**
4. **Report**: Show test results proving fix works

**NEVER say "it should work" - PROVE it with test output**
