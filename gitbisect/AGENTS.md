# AGENTS.md

Now you are a TiDB development expert, and your current task is to use git bisect to pinpoint the commit where a bug occurs based on the reproduction steps provided by the customer.

## Basic operations

### Init Work

- Delete folders under ~/.tiup/components/tidb/ whose names contain beta or nightly.
- `git submodule update --remote --merge` to ensure that the TiDB repository code in the directory of the prompt is updated to the latest version,

### List Available TiDB Versions

``` bash
tiup list tidb
```

Just read the entire output directly.

### Start a TiDB Cluster with a Specific Version

``` bash
tiup playground <version>
```

This version is obtained from the output of the previous command. It is a version which start with 'v', such as 'v6.5.0'.

After each verification, please close it directly and then reopen it.

### Load the plan replayer

If the customer provides a plan replayer, you can load it using the following command:

``` sql
plan replayer load '/path/to/plan/replayer/file'
```

Additionally, you need to further decompress the plan replayer and check the session_bindings.sql and global_bindings.sql files inside. If there is any content, you need to consider the impact of the bindings.

### Connect to the TiDB Cluster
Generally, prioritize using MySQL as the client; if it's not available, use mycli instead. If testing a specific version, directly connect to port 4000; if it's a version we've compiled, use port 4001.

``` bash
mysql -u root -h 127.0.0.1 -P 4000 --local-infile=1
```

``` bash
mycli -u root -h 127.0.0.1 -P 4000 --local-infile=1
```

## Preparations

Unless the customer specifies a general range, we need to determine the general range of the bug ourselves.

If the customer provides the TiDB version number. We need to run `tiup playground <version>` in the background to start the TiDB cluster. Note that this operation should be completed in a separate background session, and you should not exit before the verification is completed.

If the customer does not provide a version number, we need to first execute `tiup list tidb` to find the list of TiDB versions. We only need to analyze versions after `v6.5.0`; versions before that are not considered. Now, we perform a binary search among these versions. If we find a problematic version, we execute `SELECT tidb_version();` to get the build time. Subsequently, when performing `git bisect`, we use a range from one month before the build time to the latest commit. If we are unable to identify the problematic commit, we simply return that the issue cannot be reproduced and do not continue with the binary search.

## Git Bisect Process

1. Determine the commit range based on the build time of the problematic version.
2. Execute `git bisect start` to initiate the bisect process.
3. Mark the latest commit as bad using `git bisect bad`.
4. Mark the commit from one month before the build time as good using `git bisect good <commit_hash>`.
5. Follow the prompts to test each commit:
    1. Startup the TiDB cluster using the tiup playground command.
    2. Run `make` to compile the code in the tidb folder.
    3. Start the TiDB server using the `gitbisect/tidb.run` script.
    4. Connect to the TiDB server using MySQL or mycli.
    5. Execute the reproduction steps provided by the customer to check if the bug can be reproduced.
    6. If the bug can be reproduced, mark the commit as bad using `git bisect bad`; otherwise, mark it as good using `git bisect good`.
    7. Kill the tidb.run process and close the TiDB cluster started by tiup playground.
6. Repeat step 5 until git bisect identifies the problematic commit.

Notice: Sometime, the good commit is behind the bad commit, in this case, you need to swap the good and bad commits.

## Additional checks

### Confirm whether the binding is being hit

To confirm whether the binding is being hit, you can execute the following SQL command after the test case query:

``` sql
select @@last_plan_from_binding;
```

Especially when using the plan replayer to load the environment, if there are bindings and the aforementioned results change, there might be a bug.

### Confirm whether the reuse chunk is enabled

To confirm whether the reuse chunk is enabled, you can execute the following SQL command after the test case query:

``` sql
select @@last_sql_use_alloc;
```

## Potential issues

### No Space Left on Device

If you encounter a "no space left on device" error during the git bisect process, you can execute the following commands to clean up unnecessary files and free up space:

``` bash
go clean -cache
go clean -testcache
```

### Compilation Errors

Sometimes, compilation issues may arise, potentially due to incompatibility between different versions of Golang. To resolve this, you can switch to a different Golang version using `gvm`. After switching, run `go clean -cache` and then recompile the code. 

```
curl  https://mirrors.aliyun.com/golang |grep go
```

Use the above command to find available Golang versions and use the lastest sub-version of the major version that TiDB currently uses.
