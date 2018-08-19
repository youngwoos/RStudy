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
# lag() - 결측치면 윗 row를 아래로 내려서 채우기
df %>% 
  mutate(y = ifelse(is.na(x), lag(x), x))
```

    ##    x y
    ## 1  1 1
    ## 2  2 2
    ## 3 NA 2
    ## 4  3 3

``` r
# lead() - 결측치면 아래 row를 위로 올려서 채우기
df %>% 
  mutate(y = ifelse(is.na(x), lead(x), x))
```

    ##    x y
    ## 1  1 1
    ## 2  2 2
    ## 3 NA 3
    ## 4  3 3

``` r
# tidyr 패키지 fill() 활용
library(tidyr)

# 결측치면 윗 row를 아래로 내려서 채우기
df %>% 
  fill(x, .direction = "down")
```

    ##   x
    ## 1 1
    ## 2 2
    ## 3 2
    ## 4 3

``` r
# 결측치면 아래 row를 위로 올려서 채우기
df %>% 
  fill(x, .direction = "up")
```

    ##   x
    ## 1 1
    ## 2 2
    ## 3 3
    ## 4 3

``` r
# mutate()에 적용 - fill() 출력 값이 data.frame이므로 변수 지정해서 추출
df %>% 
  mutate(y = fill(df, x, .direction = "down")$x)
```

    ##    x y
    ## 1  1 1
    ## 2  2 2
    ## 3 NA 2
    ## 4  3 3
