#!/bin/bash
# Git Bash Playground - Comprehensive Git & Bash Commands Reference
# Run individual commands in Git Bash or terminal
# chmod +x gitbash-playground.sh && ./gitbash-playground.sh

# ============================================================================
# 1. GIT CONFIGURATION & SETUP
// ============================================================================

# Configure global user info
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Configure editor for commits
git config --global core.editor "vim"  # or nano, code, etc.

# View all configuration settings
git config --list
git config --list --global

# View configuration file location
git config --list --local

# Set color output (makes output more readable)
git config --global color.ui true

# Set default branch name
git config --global init.defaultBranch main

# Set merge strategy
git config --global pull.rebase false

# Setup line ending handling (crucial for Windows/Mac/Linux compatibility)
git config --global core.autocrlf true      # Windows
git config --global core.autocrlf input     # Mac/Linux

# ============================================================================
// 2. INITIALIZING & CLONING REPOSITORIES
// ============================================================================

# Initialize a new git repository
git init

# Initialize with specific branch name
git init -b main

# Clone a repository (https)
git clone https://github.com/user/repo.git

# Clone with specific branch
git clone -b develop https://github.com/user/repo.git

# Clone with depth (partial history - faster)
git clone --depth 1 https://github.com/user/repo.git

# Clone specific folder only (requires git 2.19+)
git clone --filter=blob:none --sparse https://github.com/user/repo.git
cd repo
git sparse-checkout set path/to/folder

# Clone using SSH (requires SSH key)
git clone git@github.com:user/repo.git

# Clone all branches locally
git clone --mirror https://github.com/user/repo.git

# ============================================================================
// 3. STAGING & COMMITTING CHANGES
// ============================================================================

# Check status of working directory
git status
git status -s              # Short format

# Show differences (unstaged changes)
git diff
git diff filename.txt      # Specific file
git diff HEAD~1            # Changes since last commit

# Show differences (staged changes)
git diff --staged
git diff --cached          # Alternative syntax

# Stage all changes
git add .
git add -A                 # Same as above

# Stage specific files
git add filename.txt
git add src/              # Stage entire directory

# Stage patches interactively (choose chunks)
git add -p
git add --patch           # Alternative syntax

# Unstage files
git restore --staged filename.txt
git reset HEAD filename.txt  # Older syntax

# Remove files from staging
git reset .               # Unstage all
git reset HEAD~1          # Undo last commit (keep changes)

# Commit changes
git commit -m "Commit message"

# Commit with detailed message
git commit -m "Subject line" -m "Detailed description of changes"

# Commit with multiline message (opens editor)
git commit

# Commit all tracked changes (skip staging area)
git commit -am "Skip git add for tracked files"

# Amend last commit (add forgotten changes or fix message)
git commit --amend
git commit --amend --no-edit    # Keep same message

# Commit without verification hooks
git commit --no-verify

# ============================================================================
// 4. VIEWING HISTORY & LOGS
// ============================================================================

# View commit log
git log
git log --oneline          # One commit per line
git log --graph --oneline --all  # Visual branch graph

# Show logs with author and date
git log --pretty=format:"%h - %an, %ar : %s"

# Show specific number of commits
git log -5
git log --max-count=10

# Show logs since date
git log --since="2024-01-01"
git log --until="2024-12-31"

# Show logs by author
git log --author="John"
git log --author="John\|Jane"  # Multiple authors

# Show logs by commit message
git log --grep="bug fix"

# Search by content (find commits that added/removed text)
git log -S "searchText"
git log -G "regex_pattern"     # Using regex

# Show logs for specific file
git log filename.txt
git log -p filename.txt        # Include changes

# Show commits not in other branch
git log main..develop          # Commits in develop not in main

# Show detailed log with statistics
git log --stat
git log --name-status          # Show added/modified/deleted files

# Show commit details
git show commit_hash
git show HEAD~2                # Show 2 commits ago

# Show file content at specific commit
git show commit_hash:filename.txt

# View reflog (history of branch changes)
git reflog
git reflog show branch_name

# ============================================================================
// 5. BRANCHING OPERATIONS
// ============================================================================

# List local branches
git branch
git branch -v               # With last commit

# List all branches (local & remote)
git branch -a
git branch -av              # With details

# Create new branch
git branch new-feature

# Create and checkout new branch (in one command)
git checkout -b new-feature
git switch -c new-feature   # Modern syntax

# Switch to existing branch
git checkout develop
git switch develop          # Modern syntax

# Switch to previous branch
git checkout -

# Rename branch
git branch -m old-name new-name
git branch -m new-name      # Rename current branch

# Delete branch
git branch -d branch-name       # Safe delete (prevents loss)
git branch -D branch-name       # Force delete

# Delete remote branch
git push origin --delete branch-name
git push origin :branch-name    # Old syntax

# Set upstream branch (link local to remote)
git branch -u origin/main
git branch --set-upstream-to=origin/main

# Track remote branch
git checkout --track origin/feature-branch

# Compare branches
git diff main..feature-branch
git log main..feature-branch

# ============================================================================
// 6. MERGING & REBASING
// ============================================================================

# Merge branch into current branch
git merge develop
git merge --no-ff develop      # Create merge commit (preserves history)
git merge --squash develop     # Squash all commits into one

# Merge specific commit
git merge commit_hash

# Abort merge if conflicts
git merge --abort

# Rebase current branch onto another
git rebase main

# Interactive rebase (edit, squash, reorder commits)
git rebase -i HEAD~3           # Last 3 commits
git rebase -i origin/main      # Rebase onto remote

# Continue rebase after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort

# Skip a commit during rebase
git rebase --skip

# Autosquash (automatically squash commits with "fixup!")
git rebase -i --autosquash main

# Rebase with preserve merges
git rebase -p main

# ============================================================================
// 7. STASHING (TEMPORARY STORAGE)
// ============================================================================

# Stash current changes (temporarily save work)
git stash
git stash save "Work in progress"

# List stashes
git stash list

# Apply stash (keeps stash in list)
git stash apply
git stash apply stash@{0}      # Specific stash
git stash apply stash@{2}

# Pop stash (apply and remove from list)
git stash pop
git stash pop stash@{0}

# Show stash contents
git stash show
git stash show -p              # Show actual changes

# Drop stash
git stash drop stash@{0}
git stash clear                # Delete all stashes

# Stash untracked files too
git stash -u
git stash --include-untracked

# Stash specific files
git stash push filename.txt

# Create branch from stash
git stash branch new-branch

# ============================================================================
// 8. UNDOING & REVERTING CHANGES
// ============================================================================

# Discard changes in working directory (DANGEROUS!)
git checkout filename.txt      # Single file
git checkout .                 # All files

# Discard changes (modern syntax)
git restore filename.txt
git restore .

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Undo last 3 commits
git reset --hard HEAD~3

# Reset to specific commit
git reset commit_hash

# Reset file to specific commit
git checkout commit_hash -- filename.txt

# Revert commit (create new commit that undoes changes)
git revert commit_hash
git revert HEAD                # Revert last commit

# Clean untracked files
git clean -f                   # Delete untracked files
git clean -fd                  # Delete untracked files and directories
git clean -fdx                 # Also delete ignored files

# Show what clean will remove (dry run)
git clean -fdn

# ============================================================================
// 9. REMOTE OPERATIONS
// ============================================================================

# List remote repositories
git remote
git remote -v                  # Verbose (with URLs)

# Add remote repository
git remote add origin https://github.com/user/repo.git
git remote add upstream https://github.com/upstream/repo.git

# Show remote details
git remote show origin

# Change remote URL
git remote set-url origin https://github.com/user/repo.git

# Remove remote
git remote remove origin

# Rename remote
git remote rename origin upstream

# Fetch updates from remote (doesn't modify local branches)
git fetch
git fetch origin
git fetch --all                # All remotes

# Fetch and prune (remove deleted remote branches)
git fetch --prune

# Pull (fetch + merge)
git pull
git pull origin main

# Pull with rebase instead of merge
git pull --rebase

# Push changes to remote
git push
git push origin main
git push -u origin branch-name # Set upstream and push

# Push all branches
git push --all

# Push specific branch
git push origin feature-branch

# Push with force (DANGEROUS! - overwrites remote)
git push --force
git push --force-with-lease    # Safer version of force push

# Push tags
git push origin --tags
git push origin v1.0.0         # Specific tag

# ============================================================================
// 10. TAGGING (RELEASES & MILESTONES)
// ============================================================================

# Create lightweight tag
git tag v1.0.0

# Create annotated tag (recommended)
git tag -a v1.0.0 -m "Release version 1.0.0"

# Create tag at specific commit
git tag v1.0.0 commit_hash

# List tags
git tag
git tag -l "v1.*"              # Pattern matching

# Show tag details
git show v1.0.0

# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
git push origin :v1.0.0        # Old syntax

# Push tag to remote
git push origin v1.0.0
git push origin --tags         # Push all tags

# Checkout specific tag
git checkout v1.0.0

# ============================================================================
// 11. SEARCHING & BLAME
// ============================================================================

# Search for text in commit history
git log -S "searchText"

# Search in current code
git grep "searchText"
git grep -i "SearchText"       # Case insensitive

# Show who changed each line
git blame filename.txt

# Blame with commit message
git blame -l filename.txt

# Blame specific line range
git blame -L 10,20 filename.txt

# Find commits that changed line
git log -p -S "searchText" -- filename.txt

# Find commits by message
git log --grep="bug"

# ============================================================================
// 12. CHERRY-PICK & PATCH
// ============================================================================

# Cherry-pick (apply specific commit to current branch)
git cherry-pick commit_hash
git cherry-pick commit_hash1 commit_hash2  # Multiple commits

# Cherry-pick without committing
git cherry-pick --no-commit commit_hash

# Continue cherry-pick after resolving conflicts
git cherry-pick --continue

# Abort cherry-pick
git cherry-pick --abort

# Create patch from commits
git format-patch -1            # Last commit
git format-patch -3 HEAD       # Last 3 commits

# Apply patch
git apply patchfile.patch
git am patchfile.patch         # Using mail format

# ============================================================================
// 13. WORKING WITH CONFLICTS
// ============================================================================

# Show merge conflicts
git status                     # Will show conflicted files
git diff                       # Show conflicts

# Show all conflicts
git diff --name-only --diff-filter=U

# Resolve conflicts (edit files manually, then:)
git add resolved-file.txt
git commit -m "Resolve conflicts"

# Resolve by taking ours (local)
git checkout --ours filename.txt
git add filename.txt

# Resolve by taking theirs (remote)
git checkout --theirs filename.txt
git add filename.txt

# Use merge tool
git mergetool

# Abort merge
git merge --abort

# ============================================================================
// 14. USEFUL ALIASES & SHORTCUTS
// ============================================================================

# Create aliases (shortcuts for long commands)
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'restore --staged'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --graph --oneline --all'
git config --global alias.amend 'commit --amend --no-edit'

# View aliases
git config --get-regexp alias

# ============================================================================
// 15. ADVANCED GIT WORKFLOWS
// ============================================================================

# Squash commits before merging (for clean history)
git rebase -i HEAD~3
# Mark 'pick' for first, 'squash' for rest

# Cherry-pick commits from another branch
git cherry-pick branch-name..develop

# Find common ancestor of two branches
git merge-base main develop

# Show commits in feature that aren't in main
git log main..feature

# Bisect (binary search to find breaking commit)
git bisect start
git bisect bad HEAD            # Mark current as bad
git bisect good v1.0.0         # Mark version as good
# Test current commit, then:
git bisect good               # or 'git bisect bad'
# Repeat until found

# Show file deletion history
git log --follow -p -- filename.txt

# View all changes to specific function
git log -L :function_name:filename.txt

# ============================================================================
// 16. GIT HOOKS (AUTOMATED ACTIONS)
// ============================================================================

# Hook locations: .git/hooks/

# Example pre-commit hook (run before committing)
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running tests before commit..."
npm test
if [ $? -ne 0 ]; then
  echo "Tests failed. Aborting commit."
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit

# Example commit-msg hook (validate message)
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
if ! grep -qE "^(feat|fix|docs|style|refactor|perf|test|chore)" $1; then
  echo "Commit message must start with: feat, fix, docs, style, refactor, perf, test, chore"
  exit 1
fi
EOF
chmod +x .git/hooks/commit-msg

# ============================================================================
// 17. BASH SCRIPTING FUNDAMENTALS
// ============================================================================

# Variables
name="John"
age=30
echo "Hello $name, you are $age years old"

# Command substitution
current_date=$(date)
files=$(ls -l)

# Arrays
fruits=("apple" "banana" "cherry")
echo ${fruits[0]}              # First element
echo ${fruits[@]}              # All elements
echo ${#fruits[@]}             # Array length

# String operations
str="Hello World"
echo ${str:0:5}                # Substring (first 5 chars)
echo ${str#Hello }             # Remove prefix
echo ${str% World}             # Remove suffix

# Conditionals
if [ $age -gt 18 ]; then
  echo "Adult"
else
  echo "Minor"
fi

# Multiple conditions
if [ $age -gt 18 ] && [ $name = "John" ]; then
  echo "Adult named John"
fi

# Case statement
case $name in
  John)
    echo "Hello John"
    ;;
  Jane)
    echo "Hello Jane"
    ;;
  *)
    echo "Unknown"
    ;;
esac

# Loops
for i in {1..5}; do
  echo "Number: $i"
done

# Loop through files
for file in *.txt; do
  echo "Processing $file"
done

# While loop
count=0
while [ $count -lt 5 ]; do
  echo "Count: $count"
  count=$((count + 1))
done

# Functions
greet() {
  local name=$1
  echo "Hello $name"
}
greet "World"

# ============================================================================
// 18. GIT + BASH INTEGRATION SCRIPTS
// ============================================================================

# Create new feature branch with current date
create_feature() {
  branch_name="feature/$(date +%Y%m%d)-$1"
  git checkout -b "$branch_name"
  echo "Created branch: $branch_name"
}

# Quick commit with date
quick_commit() {
  git add .
  git commit -m "Update: $(date +%Y-%m-%d' '%H:%M:%S) - $1"
}

# Show branch statistics
branch_stats() {
  echo "=== Repository Statistics ==="
  echo "Total commits: $(git rev-list --count HEAD)"
  echo "Total branches: $(git branch -a | wc -l)"
  echo "Authors:"
  git log --format='%an' | sort -u | wc -l
}

# Clone and setup
clone_and_setup() {
  repo_url=$1
  repo_name=$(basename "$repo_url" .git)
  git clone "$repo_url"
  cd "$repo_name"
  git remote -v
  echo "Repository cloned and ready"
}

# Delete local branch and remote
delete_branch() {
  branch=$1
  git branch -D "$branch"
  git push origin --delete "$branch"
  echo "Branch $branch deleted locally and remotely"
}

# Sync fork with upstream
sync_fork() {
  git fetch upstream
  git checkout main
  git merge upstream/main
  git push origin main
  echo "Fork synced with upstream"
}

# Clean old branches
cleanup_branches() {
  echo "Deleting merged branches..."
  git branch --merged | grep -v "\*" | xargs -n 1 git branch -d
  echo "Cleanup complete"
}

# ============================================================================
// 19. PERFORMANCE & OPTIMIZATION
// ============================================================================

# Garbage collection (optimize repository)
git gc

# Aggressive garbage collection
git gc --aggressive

# Check repository integrity
git fsck
git fsck --full

# Prune unused objects
git prune

# Show repository size
du -sh .git
git count-objects -v

# Shallow clone (faster for large repos)
git clone --depth 1 https://github.com/user/repo.git

# Partial clone (sparse checkout)
git clone --filter=blob:none --sparse https://github.com/user/repo.git

# ============================================================================
// 20. TROUBLESHOOTING & RECOVERY
// ============================================================================

# Recover deleted branch (using reflog)
git reflog
git checkout -b recovered-branch commit_hash

# Find lost commits
git fsck --lost-found

# Restore file from specific commit
git checkout commit_hash -- filename.txt

# Show all commits (including unreachable)
git log --all --graph --decorate --oneline

# Undo rebase
git reflog
git reset --hard original_head_commit

# Show who removed a branch
git reflog delete

# View all refs
git show-ref

# ============================================================================
// 21. USEFUL BASH COMMANDS IN GIT PROJECTS
// ============================================================================

# Count lines of code
find . -name "*.js" -o -name "*.py" | xargs wc -l

# Find large files
find . -type f -exec du -h {} + | sort -rh | head -20

# List all authors
git log --format='%an' | sort -u

# Commit count per author
git log --format='%an' | sort | uniq -c | sort -rn

# Show most recently modified files
git log -r --name-only --pretty=format: | sort | uniq -c | sort -rn

# Search for TODO comments
grep -r "TODO" --include="*.js" --include="*.py"

# Remove trailing whitespace in all files
find . -type f -exec sed -i 's/[[:space:]]*$//' {} +

# ============================================================================
// 22. WORKFLOW EXAMPLES
// ============================================================================

# Feature branch workflow
git checkout -b feature/new-feature
# ... make changes ...
git add .
git commit -m "Add new feature"
git push -u origin feature/new-feature
# Create pull request on GitHub
git checkout main
git pull origin main
git merge --no-ff feature/new-feature
git push origin main

# Hotfix workflow (from main)
git checkout -b hotfix/critical-fix
# ... fix bug ...
git add .
git commit -m "Fix critical bug"
git checkout main
git merge --no-ff hotfix/critical-fix
git push origin main

# Rebase and squash before PR
git checkout feature-branch
git rebase -i origin/main
git push --force-with-lease

# Sync local with remote (discard local changes)
git fetch origin
git reset --hard origin/main

# ============================================================================
// 23. SHELL INITIALIZATION (Add to .bashrc or .zshrc)
// ============================================================================

# Show git branch in prompt
PS1='[\u@\h \W$(git branch 2>/dev/null | grep "^*" | colrm 1 2)]\$ '

# Git completion
if [ -f /etc/bash_completion.d/git ]; then
  . /etc/bash_completion.d/git
fi

# Useful git functions
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline'
alias gp='git push'
alias gpu='git pull'

# ============================================================================
// 24. BEST PRACTICES & CONVENTIONS
// ============================================================================

/*
=== COMMIT MESSAGE CONVENTIONS ===
Format: <type>(<scope>): <subject>

Types: feat, fix, docs, style, refactor, perf, test, chore
Examples:
  feat(auth): add login functionality
  fix(api): resolve connection timeout issue
  docs(readme): update installation instructions

=== BRANCH NAMING CONVENTIONS ===
  feature/description
  fix/issue-number
  hotfix/critical-issue
  docs/update-readme
  refactor/module-cleanup

=== COMMIT BEST PRACTICES ===
- Commit frequently (atomic commits)
- Write clear messages (50 char subject, wrap at 72)
- Include context (why, not just what)
- Test before committing
- Keep commits focused on single change

=== CODE REVIEW GUIDELINES ===
- Create pull requests for all changes
- Request reviews from team members
- Respond to feedback constructively
- Keep PRs focused and reasonably sized
- Squash commits before merging

=== SECURITY BEST PRACTICES ===
- Never commit sensitive data (passwords, keys)
- Use .gitignore for secrets
- Use environment variables for configs
- Remove sensitive data from history: git-filter-repo
- Sign commits with GPG (git commit -S)
*/

# ============================================================================
// 25. USEFUL ONELINERS
// ============================================================================

# Count commits by author
git shortlog -s -n

# Show most changed files
git log --name-only --oneline | grep -v '^$' | sort | uniq -c | sort -rn | head -20

# Show deletion patterns
git log --diff-filter=D --summary | grep delete

# Find commits that changed specific function
git log -S"function_name" -p

# Show files changed in last 10 commits
git diff --name-only HEAD~10..HEAD

# List all files ever committed
git log --pretty=format: --name-only --diff-filter=D | sort -u

# Show all developers and their commits
git log --oneline | awk '{print $1}' | xargs -I {} git show {} --format="%an" -s | sort | uniq -c | sort -rn

# Create a git archive (compressed backup)
git archive --format=tar.gz --output=backup.tar.gz HEAD

echo "Git Bash Playground - Ready to use!"
echo "Copy commands and run individually in Git Bash or terminal"
