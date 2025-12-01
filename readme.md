# git-by-numbers

Operate on git status entries by numeric index — diff, add, restore, rm, and more.

This tool prints a stable, NUL-safe numbered listing of `git status` entries (indices start at 0) and lets you run common git actions (diff, add, restore, checkout, rm) by referring to those indices. It supports ranges (2-5), comma-separated lists (0,3,7), staged vs worktree actions, dry-run, and confirmation prompts for destructive actions.

Features

- `status` prints an indexed list: index, XY porcelain status, and file path
- `diff` / `diff --staged`
- `add`
- `restore` / `restore --staged` (with confirmation unless `--yes` supplied)
- `checkout` (checkout file from HEAD)
- `rm` / `rm --cached`
- Filenames with spaces, special characters, or newlines are supported (uses `git status --porcelain -z`)

Example usage

- Show numbered status:
  gbn status

- Diff indices 0 and range 3-5:
  gbn diff 0,3-5

- Add index 4:
  gbn add 4

- Restore from index 2 (staged version):
  gbn restore -s 2

Installation (manual for zsh)

1. Ensure you have a directory in your PATH, e.g. `~/bin`:

   ```bash
   mkdir -p ~/bin
   echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. Copy the script into `~/bin` and make it executable:
   ```bash
   curl -o ~/bin/gbn https://raw.githubusercontent.com/miccou/git-by-numbers/main/gbn
   chmod +x ~/bin/gbn
   ```
