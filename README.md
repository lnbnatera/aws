# AWS

## Directory Structure

| Directory | Contents                        |
|-----------|---------------------------------|
| iam       | All AWS IAM related information |
| ec2       | All AWS EC2 related information |

## git cheatsheet
### Basics
- Create branch
```
$ git branch <branch_name>
```
- Switch branch
```
$ git checkout <branch_name>
```
- Delete branch
```
$ git branch <-d|--delete> <branch_name>
$ git branch <-D|--delete --force> <branch_name>  # Force delete a branch
$ git push origin --delete <branch_name>          # Delete remote branch
```
- Check state of branch against remote
```
$ git status
```
- Add new files/directories
$ git add <file|directory>
```
- Commit changes
```
$ git commit -a
```
- Push changes to remote repository
```
$ git push origin <branch_name>
```
- Display branches
```
$ git branch                 # Display local branches only
$ git branch <-r|--remotes>  # Display remote tracking branches only
$ git branch <-a|--all>      # Display both remote tracking and local branches
```
- Get help
```
$ git help -a            # Show syntax guide for git and list subcommands
$ git help <subcommand>  # Show man page of git subcommand
```
### Add a remote repository
- Add a remote repository under the name <repo_name>
```
$ git remote
origin
$ git remote add <repo_name> <url>
$ git remote
origin
<repo_name>
$ git fetch <repo_name>
$ git branch -r
origin/HEAD -> origin/master
origin/master
origin/<branch_1>
origin/<branch_2>
origin/<branch_#>
<repo_name>/master
<repo_name>/<branch_1>
<repo_name>/<branch_2>
<repo_name>/<branch_#>
```
- Pull contents of remote branch to local branch
```
$ git pull <repo_name> <branch_name>
```
