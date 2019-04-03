## Prepare build artifact

Get public cookbooks:

```
$ berks vendor public-cookbooks
```


## Run chef-solo

 ```
 chef-solo -c ./solo.rb -j ./config.json --config-option fips=false
 ```
