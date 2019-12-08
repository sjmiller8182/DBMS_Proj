############################################################# Normalized below
--set dfs.block.size=268435456; --this is for the 256MB blocks
--set dfs.block.size=134217728; --this is for the 128MB blocks
set dfs.block.size=67108864; --this is for the 64MB blocks

select i.report_dtm, i.report_date, i.report_time, i.symbol, i.market, c.company_name, i.trade_volume, i.open_price, i.close_price, i.high_price, i.low_price, d.open_price, d.close_price, d.high_price, d.low_price
, t.tweet_id, t.tweet_text, t.tweet_date, t.tweet_time, t.user_id, t.tweet_symbol_id, tht.hashtag_id, u.url_id, u.url, bi.open_bollinger_band_lower, bi.open_bollinger_band_middle, bi.open_bollinger_band_upper, bi.close_bollinger_band_lower
, bi.close_bollinger_band_middle, bi.close_bollinger_band_upper, bi.high_bollinger_band_lower, bi.high_bollinger_band_middle, bi.high_bollinger_band_upper, bi.low_bollinger_band_lower, bi.low_bollinger_band_middle, bi.low_bollinger_band_upper
, ei.exponential_ma_low, ei.exponential_ma_open, ei.exponential_ma_high, ei.exponential_ma_close, mi.macd_open, mi.macd_hist_open, mi.mkacd_signal_open, mi.macd_close, mi.macd_hist_close, mi.mkacd_signal_close, mi.macd_high, mi.macd_hist_high
, mi.mkacd_signal_high, mi.macd_low, mi.macd_hist_low, mi.mkacd_signal_low, si.slowd_stochastic, si.slowk_stochastic
from ds7330_term_project_normalized.intraday i
left join ds7330_term_project_normalized.twitter_tweet t
	on i.symbol = t.tweet_symbol_id
	and substring(i.report_date, 3, 8) = t.tweet_date
left join ds7330_term_project_normalized.twitter_tweet_hashtag tht
	on t.tweet_id = tht.tweet_id
left join ds7330_term_project_normalized.twitter_hashtag ht
	on tht.hashtag_id = ht.hashtag_id
left join ds7330_term_project_normalized.twitter_tweet_mention m
	on t.tweet_id = m.tweet_id
left join ds7330_term_project_normalized.twitter_tweet_url tu
	on t.tweet_id = tu.tweet_id
left join ds7330_term_project_normalized.twitter_url u
	on u.url_id = tu.url_id
left join ds7330_term_project_normalized.twitter_user us
	on us.user_id = t.user_id
left join ds7330_term_project_normalized.bollinger_intraday bi
	on i.report_date = bi.report_date
	and i.report_time = bi.report_time
	and i.symbol = bi.symbol
left join ds7330_term_project_normalized.exp_ma_intraday ei
	on i.report_date = ei.report_date
	and i.report_time = ei.report_time
	and i.symbol = ei.symbol
left join ds7330_term_project_normalized.moving_averages_intraday mi  
	on i.report_date = mi.report_date
	and i.report_time = mi.report_time
	and i.symbol = mi.symbol
left join ds7330_term_project_normalized.stochastic_intraday si  
	on i.report_date = si.report_date
	and i.report_time = si.report_time
	and i.symbol = si.symbol
left join ds7330_term_project_normalized.companies c
	on i.symbol = c.symbol
	and i.market = c.market_exchange
left join ds7330_term_project_normalized.daily d
	on i.report_date = d.report_date
	and i.symbol = d.symbol
	and i.market = d.market
left join ds7330_term_project_normalized.dates dt
	on i.report_date = dt.report_date
left join ds7330_term_project_normalized.times tm
	on i.report_time = tm.report_time
group by i.report_dtm, i.report_date, i.report_time, i.symbol, i.market, c.company_name, i.trade_volume, i.open_price, i.close_price, i.high_price, i.low_price, d.open_price, d.close_price, d.high_price, d.low_price
, t.tweet_id, t.tweet_text, t.tweet_date, t.tweet_time, t.user_id, t.tweet_symbol_id, tht.hashtag_id, u.url_id, u.url, bi.open_bollinger_band_lower, bi.open_bollinger_band_middle, bi.open_bollinger_band_upper, bi.close_bollinger_band_lower
, bi.close_bollinger_band_middle, bi.close_bollinger_band_upper, bi.high_bollinger_band_lower, bi.high_bollinger_band_middle, bi.high_bollinger_band_upper, bi.low_bollinger_band_lower, bi.low_bollinger_band_middle, bi.low_bollinger_band_upper
, ei.exponential_ma_low, ei.exponential_ma_open, ei.exponential_ma_high, ei.exponential_ma_close, mi.macd_open, mi.macd_hist_open, mi.mkacd_signal_open, mi.macd_close, mi.macd_hist_close, mi.mkacd_signal_close, mi.macd_high, mi.macd_hist_high
, mi.mkacd_signal_high, mi.macd_low, mi.macd_hist_low, mi.mkacd_signal_low, si.slowd_stochastic, si.slowk_stochastic
limit 75000


