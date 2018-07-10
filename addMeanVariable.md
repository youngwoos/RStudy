여러 변수의 평균으로 구성된 파생변수 추가하기
================
2018-07-10

### `mean()`을 이용해 파생변수를 추가하면 안 되는 이유

`mean()`은 지정한 하나의 변수에 대해 평균을 구할 때 사용하는 함수다. `mean()`에 데이터 프레임의 변수를 지정하면, 해당 변수의 전체 행을 이용해 평균을 산출한다.

``` r
df <- data.frame(var1 = c(1, 2, 3),
                 var2 = c(3, 4, 5),
                 var3 = c(5, 6, 7))

df
```

    ##   var1 var2 var3
    ## 1    1    3    5
    ## 2    2    4    6
    ## 3    3    5    7

``` r
mean(df$var1)
```

    ## [1] 2

`mean()`을 이용해 파생변수를 추가하면 **지정한 변수의 전체 행으로 평균을 구해 모든 행에 일괄적으로 추가**한다. 아래 코드를 실행하면 모든 행의 `var_mean`에 `mean(df$var1)`의 결괏값 `2`가 추가되는 것을 볼 수 있다.

``` r
df$var_mean <- mean(df$var1)
df
```

    ##   var1 var2 var3 var_mean
    ## 1    1    3    5        2
    ## 2    2    4    6        2
    ## 3    3    5    7        2

`mean()`에 여러 변수를 지정해 파생변수를 만들면, **지정된 모든 변수로 하나의 평균을 구해 모든 행에 일괄적으로 추가**한다. 아래 코드를 실행하면 `mean(c(df$var1, df$var2))`의 결괏값 `3`이 모든 행에 추가된다.

``` r
df$var_mean <- mean(c(df$var1, df$var2))
df
```

    ##   var1 var2 var3 var_mean
    ## 1    1    3    5        3
    ## 2    2    4    6        3
    ## 3    3    5    7        3

> `mean()` 기본 사용법은 [다음 글](https://github.com/youngwoos/RStudy/blob/master/mean.md) 참조

### 여러 변수의 평균으로 구성된 파생변수 추가하기

#### 1. 내장 함수를 이용해 평균 파생변수 추가하기

여러 변수의 평균으로 구성된 파생변수를 추가하려면, 데이터 프레임명에 `$`를 붙여 새로 만들 변수명을 입력하고, `<-`로 계산 공식을 할당하는 형태로 코드를 작성하면 된다.

``` r
df$var_mean <- (df$var1 + df$var2)/2
df
```

    ##   var1 var2 var3 var_mean
    ## 1    1    3    5        2
    ## 2    2    4    6        3
    ## 3    3    5    7        4

그러나 이런 방식은 아래와 같이 변수의 수가 많아질수록 코드가 길어지는 단점이 있다.

``` r
df$var_mean <- (df$var1 + df$var2 + df$var3)/3
```

#### 2. `dplyr` 패키지의 `mutate()`를 이용해 평균 파생변수 추가하기

`dplyr` 패키지의 `mutate()`를 이용하면 데이터 프레임명을 반복 입력하지 않기 때문에 코드를 간소화할 수 있다.

``` r
library(dplyr)
df <- df %>% 
  mutate(var_mean = (var1 + var2 + var3)/3)
df
```

    ##   var1 var2 var3 var_mean
    ## 1    1    3    5        3
    ## 2    2    4    6        4
    ## 3    3    5    7        5

##### `rowMeans()`와 `select()`를 활용해 평균 파생변수 추가하기

`mutate()`를 활용하는 방식이 간편하긴 하지만, 여전히 변수가 늘어나면 `+` 기호를 반복하고 변수의 개수를 직접 입력해야 하는 번거로움이 있다. 이럴 때, 행 전체 평균을 구하는 `rowMeans()`와 변수를 선택하는 `select()`를 사용하면 코드를 간소화할 수 있다. `rowMeans()`에 `select()`를 중첩하고, 데이터 프레임명과 평균을 구하는데 사용할 변수를 나열하면 된다.

``` r
df <- df %>% 
  mutate(var_mean = rowMeans(select(df, var1, var2, var3)))
df
```

    ##   var1 var2 var3 var_mean
    ## 1    1    3    5        3
    ## 2    2    4    6        4
    ## 3    3    5    7        5

`select()`는 아래와 같이 다양한 방법으로 변수를 지정할 수 있기 때문에, 변수가 많을 때 특히 유용하다.

``` r
# 변수의 순서로 지정
df %>% mutate(var_mean = rowMeans(select(df, 1, 2, 3))) 

# `:`을 이용해 순서대로 나열된 변수를 한 번에 지정
df %>% mutate(var_mean = rowMeans(select(df, 1:3)))

# var1, var2, var3처럼 `변수명+숫자`의 형태로 변수명이 반복될 경우, `:`을 이용해 연속된 변수를 한 번에 지정
df %>% mutate(var_mean = rowMeans(select(df, var1:var3))) 
```

> \[참고\] `dplyr` 패키지 함수들은 코드 앞부분에 `%>%`를 이용해 데이터 프레임을 한번 지정하고 나면 뒤이어 나오는 변수 앞에는 데이터 프레임명을 반복 입력하지 않아도 된다는 장점이 있다. 하지만 `rowMeans()`는 데이터 프레임(또는 2차원 이상의 array)을 입력받아 작동하는 함수이기 때문에, `rowMeans()`에 중첩한 `select()`에는 데이터 프레임명을 지정해줘야 한다. 앞에서 지정한 데이터 프레임을 그대로 사용할 경우, 아래와 같은 방식으로 데이터 프레임명 대신 `.`을 입력해도 된다.

``` r
df %>% mutate(var_mean = rowMeans(select(., var1:var3)))
```
