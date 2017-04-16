# Git User Services ![GitHubCat](https://github.com/favicon.ico)

Small application with own service-based architecture.

### Main purpose:
Changing git user in .gitconfig by round-robin.

### Usage:
1. Separate user configuration lines must be commented in _<.gitconfig>_:
```bash
    [user]
        # email = sample-user-1@gmail.com
        # name = Sample User 1
        email = sample-user-2@gmail.com
        name = Sample User 2
        # email = sample-user-3@gmail.com
        # name = Sample User 3
```

2. Execute by
```bash
    ruby actions/change.rb
```
3. After successful execution you will receive information about current user:
```bash
    ## Email was replaced to sample-user-3@gmail.com ##
    ## Name was replaced to Sample User 3 ##
    ## <.gitconfig> was changed successfully! ##
```
Also you can execute code in silent mode - just pass `silent: true` to `Change::Process` service.
4. Current user will be changed to next in order:
```bash
    [user]
    	# email = sample-user-1@gmail.com
    	# name = Sample User 1
    	# email = sample-user-2@gmail.com
    	# name = Sample User 2
    	email = sample-user-3@gmail.com
    	name = Sample User 3
```
### Script-usage:
Simplified version of application is placed in `script` folder.
1. Move to `script` folder:
```bash
    cd script
```
2. Run shell script using
```bash
    ./guser.sh
```
