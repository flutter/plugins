This directory contains resources that the Flutter team uses during 
the development of plugins.

## Luci builder file
`try_builders.json` contains the supported luci try builders 
for plugins. It follows format:
```json
{
    "builders":[
        {
            "name":"yyy",
            "repo":"plugins",
            "enabled":true
        }
    ]
}
```
This file will be mainly used in [`flutter/cocoon`](https://github.com/flutter/cocoon) 
to trigger/update pre-submit luci tasks.
