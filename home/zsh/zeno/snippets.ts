import { defineConfig } from "jsr:@yuki-yano/zeno";

export default defineConfig(({ projectRoot, currentDirectory }) => ({
  snippets: [
    {
      name: "git status",
      keyword: "gs",
      snippet: "git status --short --branch",
    },
    {
      name: "git commit",
      keyword: "gm",
      snippet: "git commit -m {{commit message}}",
    },
    {
      name: "git clone",
      keyword: "gm",
      snippet: "git clone {{repository}}",
    },
    {
      name: "branch",
      keyword: "B",
      snippet: "git symbolic-ref --short HEAD",
      context: {
        buffer: "^git\\s+checkout\\s+",
      },
      evaluate: true,
    },
    {
      name: "ls",
      keyword: "ls",
      snippet: "eza --icons always --long --git {{foo_bar}}",
    },
    {
      name: "ll",
      keyword: "ll",
      snippet: "eza --icons always --long --all --git {{foo_bar}}",
    },
    {
      name: "tree",
      keyword: "tree",
      snippet: "eza --icons always --classify always --tree {{foo_bar}}",
    },
    {
      name: "zellij open with vertical layout",
      keyword: "zb",
      snippet: "zellij --layout ~/.config/zellij/layouts/layout_vertical.kdl",
    },
    {
      name: "null",
      keyword: "null",
      snippet: ">/dev/null 2>&1",
      context: {
        lbuffer: ".+\\s",
      },
    },
    {
      name: "mkdir -p",
      keyword: "mkdir",
      snippet: "mkdir -p {{directory_name}}",
    },
    {
      name: "zellij attach",
      keyword: "za",
      snippet: "zellij attach",
    },
    {
      name: "nb edit",
      keyword: "nbe",
      snippet: "nb edit",
    },
    {
      name: "nb list",
      keyword: "nbl",
      snippet: "nb ls",
    },
    {
      name: "nb list all",
      keyword: "nbla",
      snippet: "nb ls --all",
    },
    {
      name: "nb search",
      keyword: "nbg",
      snippet: "rg '{{keyword}}' '$(nb notebooks current --path)'",
    },
  ],
}));
