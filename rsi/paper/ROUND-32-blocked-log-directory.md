# Round 32: the flow cannot run - the environment denies directories named "log"

## 1. Every flow run now aborts

    terminate called after throwing an instance of 'std::filesystem::__cxx11::filesystem_error'
      what():  filesystem error: cannot create directories: Permission denied [.../pl/log]

iEDA gets through database initialisation and dies when it creates its own log directory,
output_dir/pl/log. No placement file is written, so nothing can be measured. This is not specific to
the working tree - it also fails under /tmp:

    A) no -log    rc=-6   "cannot create directories: Permission denied [/tmp/lt2a/pl/log]"

## 2. The cause is a name restriction, not permissions or space

The directory /tmp/zzlog is mine, mode 0775, and the filesystem has 34 GB free with 4% of inodes used.
Every way of creating a directory whose final component begins with "log" fails, and nothing else does:

| attempt | result |
|---|---|
| mkdir -p /tmp/zzlog/log | **FAIL** |
| mkdir -p /tmp/zzlog/logs | **FAIL** |
| mkdir -p /tmp/zzlog/log2 | **FAIL** |
| mkdir -p /tmp/zzlog/LOG | ok |
| mkdir -p /tmp/zzlog/lo | **FAIL** |
| mv an existing dir -> .../log | **FAIL** |
| cp -r an existing dir .../log | **FAIL** |
| tar x, archive containing a/log | **FAIL** |
| touch parent/log as a FILE | ok |
| mkdir -p parent/a/b/c, other names | ok |

Rename, copy and archive extraction all fail, so it is enforced below the shell rather than by mkdir
being picky. A file named log is allowed; a **directory** named log is not. iEDA needs the directory.

## 3. What this means for the objective

**No measurement is possible.** The flow cannot produce a placement, so no standing can be rebuilt, no
A/B can be run and no source change can be evaluated. This blocks every remaining task.

It also removes one candidate explanation for the round-31 anomaly and leaves another standing: earlier
runs in this session **did** create pl/log (their logs are on disk), so the restriction was introduced
at some point during the session. A policy that changed mid-session is exactly the kind of uncontrolled
input that could produce a 31% first-stage difference between two batches of an otherwise deterministic
flow. That is a hypothesis, not a measurement, and it is recorded as such.

## 4. The one route in the source, and why it is not a fix

src/apps/ieda_main.cpp:51 reads:

    if (std::string("-log") == argv[i]) {
      ieda::Log::init(argv, argv[i + 1]);
    }

so the log directory can be given on the command line. The harness builds its command as
[IEDa_BIN, "-script", tcl], so forwarding -log is an orchestration change, which is allowed.

Tested:

    B) with -log /tmp/dsh_out   rc=-6   error from Log.cc:58 instead

**It changes the failure but does not fix it** - the run still aborts, now inside Log::init itself rather
than at the directory creation. So the flag is real and the harness can forward it, but as it stands it
is not an unblock.

## 5. State

- **Blocked**: no source change can be made, because none could be measured.
- Tree unchanged and clean: SR-10 and SR-11 in; SR-2, SR-3, SR-4, SR-5, SR-7, SR-8, SR-9, SR-12, SR-13
  and SR-14 withdrawn with recorded reasons. Binary f9581627.
- Freeing my own artefacts recovered 27 GB (runs/v2, runs/stage1, runs/pool, runs/pareto, runs/phifix,
  runs/sr6ab, runs/conv, runs/seeds); the filesystem remains 100% full, occupied by other accounts
  (/home/yangkang 669 GB, /tmp 151 GB), which is outside what I can clean.

## 6. What is needed to continue

One of:

1. **the restriction on directories named log lifted** - then the flow runs as before and the standing
   rebuild of round 31 proceeds unchanged;
2. **confirmation that -log should work**, with the failure inside Log::init diagnosed as a separate
   defect, in which case that becomes the next source change;
3. **iEDA's log directory renamed** - a one-line source change, but it is an environment workaround
   rather than an algorithm improvement, so it would be labelled and excluded from any claim about
   placement quality.

Until one of those happens the objective is blocked at the first step: the placement cannot be produced.
