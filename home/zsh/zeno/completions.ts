import { defineConfig } from "jsr:@yuki-yano/zeno";
import { join } from "jsr:@std/path@^1.0.0/join";

export default defineConfig(({ projectRoot, currentDirectory }) => ({
  completions: [
    {
      name: "kill signal",
      patterns: ["^kill -s $"],
      sourceCommand: "kill -l | tr ' ' '\\n'",
      options: { "--prompt": "'Kill Signal> '" },
    },
    {
      name: "kill pid",
      patterns: ["^kill( .*)? $"],
      excludePatterns: [" -[lns] $"],
      sourceCommand: "LANG=C ps -ef | sed 1d",
      options: { "--multi": true, "--prompt": "'Kill Process> '" },
      callback: "awk '{print $2}'",
    },
    {
      name: "cd",
      patterns: ["^cd $"],
      sourceCommand:
        "find . -path '*/.git' -prune -o -maxdepth 5 -type d -print0",
      options: {
        "--read0": true,
        "--prompt": "'Chdir> '",
        "--preview": "cd {} && ls -a | sed '/^[.]*$/d'",
      },
      callback: "cut -z -c 3-",
      callbackZero: true,
    },
    {
      name: "zellij sessions",
      patterns: ["^zellij attach $"],
      excludePatterns: [" -[lns] $"],
      sourceCommand: "zellij ls --reverse",
      options: {
        "--ansi": true,
        "--prompt": "'zellij attach> '",
      },
    },
    {
      name: "nb edit",
      patterns: [
        "^nb e( .*)? $",
        "^nb edit( .*)? $",
      ],
      sourceCommand: "nb ls --no-color | rg '^\\[[0-9]+\\]'",
      options: {
        "--ansi": true,
        "--prompt": "'nb edit > '",
        "--preview": "echo {} | sed -E 's/^\\[([0-9]+)\\].*/\\1/' | xargs nb show"
      },
      callback: "sed -E 's/^\\[([0-9]+)\\].*/\\1/'"
    },
    {
      name: "nb subcommand help",
      patterns: [
        "^\s*nb\s*$",
        "^\s*nb\s+help\s*$",
      ],
      sourceCommand: "nb subcommands",
      options: {
        "--prompt": "'nb subcommand >'",
      },
    },
  ],
}));
