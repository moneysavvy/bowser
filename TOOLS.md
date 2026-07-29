# Claude Code Tools

> Bowser July 2026: start with `just preflight` and [README.md](README.md). This file is a tool-schema reference for agent authors.

TypeScript function prototypes for all available tools with parameter descriptions.

---

## File Operations

```ts
// Read a file from the local filesystem
function Read(
  file_path: string,    // Absolute path to the file to read
  limit?: number,       // Number of lines to read
  offset?: number,      // Line number to start reading from
  pages?: string,       // Page range for PDF files (e.g., "1-5", "3", "10-20")
): string;

// Perform exact string replacements in files
function Edit(
  file_path: string,       // Absolute path to the file to modify
  new_string: string,      // The text to replace it with
  old_string: string,      // The text to replace
  replace_all?: boolean,   // Replace all occurrences (default false)
): void;

// Write/overwrite a file on the local filesystem
function Write(
  content: string,      // The content to write to the file
  file_path: string,    // Absolute path to the file to write (must be absolute, not relative)
): void;

// Replace contents of a Jupyter notebook cell
function NotebookEdit(
  cell_id?: string,        // ID of the cell to edit
  cell_type?: string,      // "code" or "markdown"
  edit_mode?: string,      // "replace", "insert", or "delete"
  new_source: string,      // The new source for the cell
  notebook_path: string,  // Absolute path to the .ipynb file
): void;
```

---

## Search & Discovery

```ts
// Fast file pattern matching using glob patterns
function Glob(
  path?: string,    // Directory to search in (default: current working directory)
  pattern: string, // Glob pattern to match (e.g., "**/*.ts")
): string[];

// Search file contents using ripgrep regex
function Grep(
  "-A"?: number,             // Lines to show after each match
  "-B"?: number,             // Lines to show before each match
  "-C"?: number,             // Alias for context
  "-i"?: boolean,            // Case insensitive search
  "-n"?: boolean,            // Show line numbers (default true)
  context?: number,          // Lines of context before and after each match
  glob?: string,             // Glob pattern to filter files (e.g., "*.js")
  head_limit?: number,       // Limit output to first N entries
  multiline?: boolean,       // Enable multiline matching
  offset?: number,           // Skip first N entries before applying head_limit
  output_mode?: string,      // "content", "files_with_matches", or "count"
  path?: string,             // File or directory to search in
  pattern: string,           // The regular expression pattern to search for
  type?: string,             // File type filter (e.g., "js", "py")
): string;
```

---

## Shell Execution

```ts
// Execute a bash command with optional timeout
function Bash(
  command: string,                // The command to execute
  dangerouslyDisableSandbox?: boolean, // Override sandbox mode (use with caution)
  description?: string,           // Clear, concise description of what this command does
  run_in_background?: boolean,   // Run command in the background
  timeout?: number,               // Optional timeout in milliseconds (max 600000)
): string;
```

---

## Web

```ts
// Search the web and return results with links
function WebSearch(
  allowed_domains?: string[],   // Only include results from these domains
  blocked_domains?: string[],  // Exclude results from these domains
  query: string,                // The search query to use
): string;

// Fetch and process content from a URL
function WebFetch(
  prompt: string,  // The prompt to run on the fetched content
  url: string,     // The URL to fetch content from
): string;
```

---

## Task Management

```ts
// Create and manage a structured task list for current coding session
function TodoWrite(
  todos: Todo[],  // The updated todo list
): void;

// Retrieve output from a running or completed background task
function TaskOutput(
  block?: boolean,     // Whether to wait for completion (default true)
  task_id: string,     // The task ID to get output from
  timeout?: number,    // Max wait time in ms (default 30000)
): string;

// Stop a running background task
function TaskStop(
  shell_id?: string,   // Deprecated: use task_id instead
  task_id?: string,    // The ID of the background task to stop
): void;
```

---

## Agents & Subagents

```ts
// Launch a specialized subagent for complex tasks
function Task(
  description: string,         // Short 3-5 word description of the task
  prompt: string,              // The task for the agent to perform
  subagent_type: string,      // Agent type (e.g., "Explore", "Plan", "Bash", "general-purpose")
  max_turns?: number,         // Maximum number of agentic turns before stopping
  model?: string,             // Model to use ("sonnet", "opus", "haiku")
  resume?: string,            // Agent ID to resume from
  run_in_background?: boolean, // Run agent in background
): string;
```

---

## Planning & Mode Control

```ts
// Transition into plan mode for implementation planning
function EnterPlanMode(): void;

// Signal plan is complete and ready for user approval
function ExitPlanMode(
  allowedPrompts?: AllowedPrompt[],  // Prompt-based permissions needed to implement the plan
  pushToRemote?: boolean,            // Whether to push the plan to a remote session
  remoteSessionId?: string,          // Remote session ID if pushing to remote
  remoteSessionTitle?: string,       // Remote session title if pushing to remote
  remoteSessionUrl?: string,         // Remote session URL if pushing to remote
): void;

// Ask the user a question with selectable options
function AskUserQuestion(
  questions: Question[],  // Array of 1-4 questions to ask the user
): Record<string, string>;
```

---

## Skills (Slash Commands)

```ts
// Execute a skill/slash command within the conversation
function Skill(
  args?: string,   // Optional arguments for the skill
  skill: string,  // The skill name to invoke
): void;
```

### Available Skills

```ts
// Save and run project-specific commands (justfile/recipe alternative)
function Skill(skill: "just"): void;

// Observable browser automation using Chrome MCP tools
function Skill(skill: "claude-bowser"): void;

// Headless browser automation using Playwright CLI
function Skill(skill: "playwright-bowser"): void;

// Execute plan in batches with review checkpoints
function Skill(skill: "execute-plan"): void;

// Create detailed implementation plan with bite-sized tasks
function Skill(skill: "write-plan"): void;

// Interactive design refinement using Socratic method
function Skill(skill: "brainstorm"): void;

// Parallel user story validation via QA agents
function Skill(skill: "ui-review"): void;

// Build the codebase based on the plan
function Skill(skill: "build"): void;

// List all available tools as TypeScript function prototypes
function Skill(skill: "list-tools"): void;

// Prime context by exploring the codebase structure and README
function Skill(skill: "prime"): void;

// Visit a blog, find the latest post, summarize it, and save the summary
function Skill(skill: "bowser:blog-summarizer"): void;

// Run a saved browser automation workflow
function Skill(skill: "bowser:hop-automate"): void;

// Search Amazon, add item(s) to cart, proceed to checkout, stop
function Skill(skill: "bowser:amazon-add-to-cart"): void;
```

---

## Types

```ts
interface Todo {
  activeForm: string;   // Present continuous form shown during execution
  content: string;     // Imperative form describing what needs to be done
  status: "pending" | "in_progress" | "completed";
}

interface AllowedPrompt {
  prompt: string;  // Semantic description of the action
  tool: "Bash";   // The tool this prompt applies to
}

interface Question {
  header: string;              // Very short label displayed as a chip/tag (max 12 chars)
  multiSelect: boolean;        // Allow multiple selections
  options: QuestionOption[];   // Available choices (2-4 options)
  question: string;           // The complete question to ask
}

interface QuestionOption {
  description: string;  // Explanation of what this option means
  label: string;       // Display text for the option
  markdown?: string;   // Optional preview content shown when focused
}
```
