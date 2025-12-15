# AGENTS.md

Now you are a TiDB testing expert, and your current task is to use git bisect to pinpoint the commit where a bug occurs based on the reproduction steps provided by the customer. However, you don't need to analyze the problem through the commit information and code.

## Basic operations

### Init Work

- Delete folders under ~/.tiup/components/tidb/ whose names contain beta or nightly.
- `git submodule update --remote --merge` to ensure that the TiDB repository code in the directory of the prompt is updated to the latest version,

### List Available TiDB Versions

``` bash
tiup list tidb
```

Just read the entire output directly. It contains all available TiDB versions and release dates. The release date will help you determine the commit range for git bisect.

### Start a TiDB Cluster with a Specific Version

If the customer provides reproduction steps without tiflash, you can start a TiDB cluster for PD and TiKV using the following command:

``` bash
tiup playground nightly --mode tikv-slim &
```

If the customer provides reproduction steps with tiflash, you can start a TiDB cluster for PD, TiKV, and TiFlash using the following command:

``` bash
tiup playground <version> &
```

This version is obtained from the output of the `tiup list tidb` command. It is a version which start with 'v', such as 'v6.5.0'.

After each verification, Please kill it.

### Load the plan replayer

If the customer provides a plan replayer, you can load it using the following command:

``` sql
plan replayer load '/path/to/plan/replayer/file'
```

Additionally, you need to further decompress the plan replayer and check the session_bindings.sql and global_bindings.sql files inside. If there is any content, you need to consider the impact of the bindings.

### How to write the test case and run it

#### Write the test case

If the users provides you with specific steps, please write those specific steps into `t/test.test` file. But the end of the file should drop the database used in the test.

If the user provides you with a plan replayer, please follow the steps below to write the test case:

1. Copy the user-provided plan replayer to the new path created under replayer in step 1. Do not modify the file name.
2. Unzip this plan replayer to `./replayer/temp` folder. Within the unzipped files, examine three files: one under the sql directory, which provides the test query, and another under the schema directory. Open any file in the schema directory; it will contain a CREATE DATABASE statement. The third one is the table_tiflash_replica.txt file, which confirms whether there is a TiFlash replica; if it is empty, it means there isn't one. Take note of this database name. Afterward, delete all the unzipped files and temporary folder.
3. Create a test file at `t/test.test`.
4. Next, write the test. The template for the test file is as follows:

```sql
drop database if exists <database_name>;
plan replayer load './relative path of the replayer file relative to the project root';

# if there is a TiFlash replica, add the following line <- here is a prompt to the agent, Don't put this comment # in the final test file
select sleep(5);

explain format = 'verbose' <test query>;
select @@last_plan_from_cache,@@last_sql_use_alloc,@@last_plan_from_binding;
drop database if exists <database name>;
```

5. Please check the test file for any syntax errors. If it has syntax errors, please fix them.

#### Run the test case and check the result

You can run the test case using the following command:

``` shell
./run-test.sh -r test -P <port>
```

the result will be in the `r/test.result` file. Please check whether the result matches the expected result provided by the customer.

### Connect to the TiDB Cluster

Generally, prioritize using MySQL as the client; if it's not available, use mycli instead. If testing a specific version, directly connect to port 4000; if it's a version we've compiled, use port 4001.

``` bash
mysql -u root -h 127.0.0.1 -P 4000 --local-infile=1
```

``` bash
mycli -u root -h 127.0.0.1 -P 4000 --local-infile=1
```

### Compile the TiDB Code and Start the TiDB Server

In the same directory as this prompt file, execute the following commands:

```bash
cd tidb
make
cd ..
sh tidb.run
```

After starting, please execute the test case in a new session without closing it until this round of testing is finished. Only then should you close the script. Make sure to close the TiDB running on port 4001, not the one on port 4000.

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

```bash
curl  https://mirrors.aliyun.com/golang |grep go
```

Use the above command to find available Golang versions and use the lastest sub-version of the major version that TiDB currently uses.

## Behavior Restrictions

- Perform binary search on the master branch first. If the issue cannot be reproduced through binary search, or the user specifies that it can be reproduced on a specific version, then binary search may be conducted on the release branch.

## Bisect Steps

For the details of the operations in the following steps, please follow the specifications and restrictions of the previous chapter.

- Prepare the test case based on the reproduction steps provided by the customer or the plan replayer.
- Complete Init Work
- Determine the commit range based on the release date from the `tiup list tidb` command or the version/commitid provided by the customer.

Unless the customer specifies a general range, we need to determine the general range of the bug ourselves.

We need to first execute `tiup list tidb` to find the list of TiDB versions and release date. We only need to analyze versions after `v6.5.0`; versions before that are not considered. Now, we perform a binary search among these versions. If we find a problematic version (How to find the problematic version, Please read `Run the test case and check the result`). If we are unable to identify the problematic commit, we simply return that the issue cannot be reproduced and do not continue with the binary search.

   1. The good commit must be submitted at least 180 days ago, but no later than the year 2022.
   2. Don't need to analyze the problem through the commit information and code.
   3. 

- Execute `git bisect start` to initiate the bisect process.
- Mark the latest commit as bad using `git bisect bad`.
- Mark the commit from one month before the build time as good using `git bisect good <commit_hash>`.
- Write the executor script to automately start test env and run the test case.
    1. Startup the TiDB cluster using the tiup playground command in the background into `./gitbisect/main.sh.
    2. Start the TiDB server using the `gitbisect/tidb.run` script in the background.
    3. Wait for a while to ensure that the TiDB server has started successfully.
    4. Connect to the TiDB server to verify that it is running.
    5. run the test case using the `./run-test.sh -r test -P <port>` command.
    6. Kill the tidb.run process and close the TiDB cluster started by `tiup playground`.
- Follow the prompts to test each commit:
    1. Run `make` to compile the code in the tidb folder.
    2. Run `sh main.sh` to start the TiDB cluster and TiDB server.
    3. Check the result in the `r/test.result` file to see if the bug can be reproduced.
    4. If the bug can be reproduced, mark the commit as bad using `git bisect bad`; otherwise, mark it as good using `git bisect good`.
    5. Kill the tidb.run process and close the TiDB cluster started by `tiup playground`.
- Repeat step 6 until git bisect identifies the problematic commit.

Notice: Sometime, the good commit is behind the bad commit, in this case, you need to swap the good and bad commits.