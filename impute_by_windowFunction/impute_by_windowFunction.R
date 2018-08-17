library(dplyr)

df <- data.frame(x=c(1,2,NA,3))
df

# lag() - 결측치면 윗 row 채우기
df %>% 
  mutate(y = ifelse(is.na(x), lag(x), x))

# lead() - 결측치면 아래 row 채우기
df %>% 
  mutate(y = ifelse(is.na(x), lead(x), x))
