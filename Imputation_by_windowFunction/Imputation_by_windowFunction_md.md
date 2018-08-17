Imputation by Window Function
================

``` r
library(dplyr)

df <- data.frame(x=c(1,2,NA,3))
df
```

    ##    x
    ## 1  1
    ## 2  2
    ## 3 NA
    ## 4  3

``` r
# lag() - 결측치면 윗 row 채우기
df %>% 
  mutate(y = ifelse(is.na(x), lag(x), x))
```

    ##    x y
    ## 1  1 1
    ## 2  2 2
    ## 3 NA 2
    ## 4  3 3

``` r
# lead() - 결측치면 아래 row 채우기
df %>% 
  mutate(y = ifelse(is.na(x), lead(x), x))
```

    ##    x y
    ## 1  1 1
    ## 2  2 2
    ## 3 NA 3
    ## 4  3 3
