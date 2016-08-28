# AWS

## Directory Structure

| Directory | Contents                        |
|-----------|---------------------------------|
| iam       | All AWS IAM related information |
| ec2       | All AWS EC2 related information |

### git cheatsheet
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
