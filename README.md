# SportsFeed

[![CI](https://github.com/r8/ylo-sports-feed/workflows/CI/badge.svg)](https://github.com/r8/ylo-sports-feed/actions?query=workflow%3ACI)

Task description: [TASK.md](./TASK.md)
JSON with sport updates: [./priv/updates.json](./priv/updates.json)

## Setup

Clone the repository: 

```bash
git clone git@github.com:r8/ylo-sports-feed.git
```

Change into the cloned directory:

```bash
cd ylo-sports-feed
```

Install Elixir and Erlang with **asdf** or **mise-en-place**. 

### asdf

1. Install [asdf](https://asdf-vm.com/guide/getting-started.html).
2. Install the required plugins:
   ```bash
   asdf plugin add erlang
   asdf plugin add elixir
   ```
3. Run `asdf install` in the cloned subfolder. This will install all the tool versions specified in the .tool_versions file.
  ```bash
  asdf install
  ```

### mise-en-place

Mise can be used as a drop-in [replacement for asdf](https://mise.jdx.dev/dev-tools/comparison-to-asdf.html). It supports the same .tool-versions files that are used with asdf.

1. Install [mise-en-place](https://mise.jdx.dev/getting-started.html).
2. Run `mise install` in the cloned subfolder. This will install all the tool versions specified in the .tool_versions file.
   ```bash
   mise install
   ```

## Running the application

1. Run `mix setup` to install and setup dependencies
2. Start Phoenix endpoint with `mix phx.server`
3. Visit [`localhost:4000`](http://localhost:4000) from your browser.
