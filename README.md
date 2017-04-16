# Git User Services ![GitHubCat](https://github.com/favicon.ico)

Small application with own service-based architecture.

### Main purpose:
Changing git user in `.gitconfig` and SSH keys by round-robin.

### Ruby version
1.9.3 and greater.

### Usage:
1. Separate users' configuration lines must be commented in `.gitconfig`:
```bash
    [user]
        # email = sample-user-1@gmail.com
        # name = Sample User 1
        email = sample-user-2@gmail.com
        name = Sample User 2
        # email = sample-user-3@gmail.com
        # name = Sample User 3
```

2. (Optional) `<.ssh>` folder must have next tree structure:
```
    <.ssh>
        - id_rsa
        - id_rsa.pub
        <git-users>
            <sample-user-1@gmail.com>
                 - id_rsa
                 - id_rsa.pub
            <sample-user-2@gmail.com>
                 - id_rsa
                 - id_rsa.pub   
```

3. Execute by
```bash
    ruby actions/change.rb
```

4. After successful execution you will receive information about current user:
```bash
    ## Email was replaced to sample-user-3@gmail.com ##
    ## Name was replaced to Sample User 3 ##
    ## SSH keys were replaced ##
    ## <.gitconfig> was changed successfully! ##
```

Also you can execute code in silent mode - just pass `silent: true` to `Change::Process` service.

5. Current user will be changed to next in order:
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
Simplified version of application is placed in `<script>` folder.
1. Move to `<script>` folder:
```bash
    cd script
```

2. Run shell script using
```bash
    ./guser.sh
```
Also you can execute code in silent mode - just pass `true` on shell script execution.
