Restaurant
================

``` r
## Recruit Restaurant Visitor Forecasting ##
library(dplyr)

## options

# stringsAsFactors
options(stringsAsFactors = F)

# 일본어 출력
Sys.setlocale("LC_ALL", "Japanese")
```

    ## [1] "LC_COLLATE=Japanese_Japan.932;LC_CTYPE=Japanese_Japan.932;LC_MONETARY=Japanese_Japan.932;LC_NUMERIC=C;LC_TIME=Japanese_Japan.932"

``` r
# 1. 데이터 불러오기 ####

## air
air_reserve <- read.csv("air_reserve.csv")
air_store_info <- read.csv("air_store_info.csv")

## hpg
hpg_reserve <- read.csv("hpg_reserve.csv")
hpg_store_info <- read.csv("hpg_store_info.csv")

store_id_relation <- read.csv("store_id_relation.csv")


# 2. air, hpg 결합 ####

# (1) air_reserve 전처리

# 변수명 확인
colnames(air_reserve)
```

    ## [1] "air_store_id"     "visit_datetime"   "reserve_datetime"
    ## [4] "reserve_visitors"

``` r
colnames(air_store_info)
```

    ## [1] "air_store_id"   "air_genre_name" "air_area_name"  "latitude"      
    ## [5] "longitude"

``` r
colnames(store_id_relation)
```

    ## [1] "air_store_id" "hpg_store_id"

``` r
# air_store_info 결합
air <- left_join(air_reserve, air_store_info, by = "air_store_id")

# store_id_relation 결합
air <- left_join(air, store_id_relation, by = "air_store_id")

# 문제점 : id 56114개 매칭 안됨
table(is.na(air$hpg_store_id))
```

    ## 
    ## FALSE  TRUE 
    ## 36264 56114

``` r
# (2) hpg_reserve 전처리

# 변수명 확인
colnames(hpg_reserve)
```

    ## [1] "hpg_store_id"     "visit_datetime"   "reserve_datetime"
    ## [4] "reserve_visitors"

``` r
colnames(hpg_store_info)
```

    ## [1] "hpg_store_id"   "hpg_genre_name" "hpg_area_name"  "latitude"      
    ## [5] "longitude"

``` r
# hpg_store_info 결합
hpg <- left_join(hpg_reserve, hpg_store_info, by = "hpg_store_id")

# store_id_relation 결합
hpg <- left_join(hpg, store_id_relation, by = "hpg_store_id")

# 문제점 : id 1,972,137개 매칭 안됨
table(is.na(hpg$air_store_id))
```

    ## 
    ##   FALSE    TRUE 
    ##   28183 1972137

``` r
# (3) air, hpg 결합

# 출처 변수 추가
air <- air %>% mutate(site = "air")
hpg <- hpg %>% mutate(site = "hpg")

# 결합
reserve <- bind_rows(air, hpg)

# 검토
nrow(air) 
```

    ## [1] 92378

``` r
nrow(hpg)
```

    ## [1] 2000320

``` r
table(reserve$site)
```

    ## 
    ##     air     hpg 
    ##   92378 2000320

``` r
nrow(air) + nrow(hpg)
```

    ## [1] 2092698

``` r
nrow(reserve)
```

    ## [1] 2092698

``` r
#**** 문제점 - air와 hpg의 store_id가 1:1 매칭 안됨 ****#

# air에 매칭 안된 row - 56,114개
table(is.na(air$hpg_store_id))
```

    ## 
    ## FALSE  TRUE 
    ## 36264 56114

``` r
# hpg에 매칭 안된 row - 1,972,137개
table(is.na(hpg$air_store_id))
```

    ## 
    ##   FALSE    TRUE 
    ##   28183 1972137

``` r
# hpg_id와 매칭 안되는 air_id 갯수 - 183개
length(setdiff(unique(air$air_store_id), 
               store_id_relation$air_store_id))
```

    ## [1] 183

``` r
# air_id와 매칭 안되는 hpg_id 갯수 - 13,175개
length(setdiff(unique(hpg$hpg_store_id), 
               store_id_relation$hpg_store_id))
```

    ## [1] 13175

``` r
#*******************************************************#


# 3. date_info 결합 ####
date_info <- read.csv("date_info.csv")


# (1) visit_datetime 기준 결합

# visit_date 변수 생성
reserve$visit_date <- as.Date(reserve$visit_datetime)

# 변수 속성 Date 통일
class(date_info$calendar_date)
```

    ## [1] "character"

``` r
date_info$calendar_date <- as.Date(date_info$calendar_date)

# 결합
reserve <- left_join(reserve, date_info, by = c("visit_date" = "calendar_date"))

# 변수명 수정 - visit, reserve 중복 변수명 방지
reserve <- reserve %>%  
  rename(visit_day_of_week = day_of_week,
         visit_holiday_flg = holiday_flg)


# (2) reserve_datetime 기준 결합

# reserve_date 변수 생성
reserve$reserve_date <- as.Date(reserve$reserve_datetime)

# 변수 속성 Date 통일
class(date_info$calendar_date)
```

    ## [1] "Date"

``` r
date_info$calendar_date <- as.Date(date_info$calendar_date)

# 결합
reserve <- left_join(reserve, date_info, by = c("reserve_date" = "calendar_date"))

# 변수명 수정
reserve <- reserve %>%  
  rename(reserve_day_of_week = day_of_week,
         reserve_holiday_flg = holiday_flg)

# 변수명 확인
colnames(reserve)
```

    ##  [1] "air_store_id"        "visit_datetime"      "reserve_datetime"   
    ##  [4] "reserve_visitors"    "air_genre_name"      "air_area_name"      
    ##  [7] "latitude"            "longitude"           "hpg_store_id"       
    ## [10] "site"                "hpg_genre_name"      "hpg_area_name"      
    ## [13] "visit_date"          "visit_day_of_week"   "visit_holiday_flg"  
    ## [16] "reserve_date"        "reserve_day_of_week" "reserve_holiday_flg"

``` r
# 4. air_visit 결합 ####
air_visit <- read.csv("air_visit_data.csv")
colnames(air_visit)
```

    ## [1] "air_store_id" "visit_date"   "visitors"

``` r
# 변수 속성 Date 통일
class(air_visit$visit_date)
```

    ## [1] "character"

``` r
air_visit$visit_date <- as.Date(air_visit$visit_date)

# 결합 - air_store_id, visit_date 모두 일치
reserve <- left_join(reserve, air_visit, 
                     by = c("air_store_id" = "air_store_id",
                            "visit_date" = "visit_date"))

table(is.na(reserve$visitors))
```

    ## 
    ##   FALSE    TRUE 
    ##  108439 1984259

``` r
# 5. air, hpg 중복 변수명 통일 ####

## genre_name

# 검토- air_genre_name, hpg_genre_name 둘 모두 있는 경우
reserve %>% filter(!is.na(air_genre_name) & !is.na(hpg_genre_name)) %>% nrow
```

    ## [1] 0

``` r
# 변수명 통합
reserve <- reserve %>% 
  mutate(genre = ifelse(!is.na(air_genre_name), air_genre_name, hpg_genre_name)) %>% 
  select(-air_genre_name, -hpg_genre_name)

# 변수 확인
colnames(reserve)
```

    ##  [1] "air_store_id"        "visit_datetime"      "reserve_datetime"   
    ##  [4] "reserve_visitors"    "air_area_name"       "latitude"           
    ##  [7] "longitude"           "hpg_store_id"        "site"               
    ## [10] "hpg_area_name"       "visit_date"          "visit_day_of_week"  
    ## [13] "visit_holiday_flg"   "reserve_date"        "reserve_day_of_week"
    ## [16] "reserve_holiday_flg" "visitors"            "genre"

``` r
## area

# 검토 - air_area_name, hpg_area_name 둘 모두 있는 경우
reserve %>% filter(!is.na(air_area_name) & !is.na(hpg_area_name)) %>% nrow
```

    ## [1] 0

``` r
# 변수명 통합
reserve <- reserve %>% 
  mutate(area = ifelse(!is.na(air_area_name), air_area_name, hpg_area_name)) %>% 
  select(-air_area_name, -hpg_area_name)

# 변수 확인
colnames(reserve)
```

    ##  [1] "air_store_id"        "visit_datetime"      "reserve_datetime"   
    ##  [4] "reserve_visitors"    "latitude"            "longitude"          
    ##  [7] "hpg_store_id"        "site"                "visit_date"         
    ## [10] "visit_day_of_week"   "visit_holiday_flg"   "reserve_date"       
    ## [13] "reserve_day_of_week" "reserve_holiday_flg" "visitors"           
    ## [16] "genre"               "area"

``` r
# 6. id 변수 생성 ####
reserve <- reserve %>% 
  mutate(id = ifelse(!is.na(air_store_id), air_store_id, hpg_store_id))

# 검토
table(is.na(reserve$id))
```

    ## 
    ##   FALSE 
    ## 2092698

``` r
colnames(reserve)
```

    ##  [1] "air_store_id"        "visit_datetime"      "reserve_datetime"   
    ##  [4] "reserve_visitors"    "latitude"            "longitude"          
    ##  [7] "hpg_store_id"        "site"                "visit_date"         
    ## [10] "visit_day_of_week"   "visit_holiday_flg"   "reserve_date"       
    ## [13] "reserve_day_of_week" "reserve_holiday_flg" "visitors"           
    ## [16] "genre"               "area"                "id"

``` r
#**************************************#
# # save
# save(reserve, file = "reserve.rda")
# 
# # load
# load("reserve.rda")
#
# reserve 외 삭제
rm(list=setdiff(ls(), "reserve"))
#**************************************#



# 6. 분석 ####

# 예약 대비 방문율 변수 생성

# 예약 대비 방문율이 높은 경우의 특징 확인 (ex. 장르, 지역, 요일, 공휴일 등) 

# 각 특징을 적합한 그래프 형태로 표현하고 이유 설명하기 

# https://www.kaggle.com/c/recruit-restaurant-visitor-forecasting/data 
```
