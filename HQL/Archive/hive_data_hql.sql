--set mapred.tasktracker.reduce|map.tasks.maximum;
set mapred.job.queue.name=root.batch; --1st run this
set mapreduce.map.memory.mb=8096; --then run this
set mapreduce.reduce.memory.mb=10020; --then run this
set mapreduce.job.reduces=30; --then run this
set hive.exec.dynamic.partition.mode=nonstrict; --then this and after, run the DML

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@ TIME-CONSTRAINED DATA FOR DECISION ANALYSIS @@@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

------------------------ loading dates table
insert into ds7330_term_project.dates( --this has been tested with data 11-2-2019
	select trim(substring(regexp_replace(times, '"', ''), 1, 10)) as report_date
	from ds7330_term_raw_data.intraday_prices_15_min
	group by trim(substring(regexp_replace(times, '"', ''), 1, 10))
);

------------------------ loading times table 
-- use unique dates from all tables
--since we are joining all tables to intraday (since this has the price data), we only need intraday time
insert into ds7330_term_project.times( --this has been tested with data 11-2-2019
	select trim(substring(regexp_replace(times, '"', ''), (length(regexp_replace(times, '"', ''))-1)-6, length(times))) as report_time
	from ds7330_term_raw_data.intraday_prices_15_min
	group by trim(substring(regexp_replace(times, '"', ''), (length(regexp_replace(times, '"', ''))-1)-6, length(times)))
);

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@@@@@@@@@ COMPANIES FOR INDUSTRY DATA @@@@@@@@@@@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

insert into ds7330_term_project.companies( --this has been tested with data 11-2-2019
	select nyse.symbol as symbol
	    , nyse.company as company_name
	    , "NYSE" as market_exchange
	from ds7330_term_raw_data.nyse_symbols nyse
	group by symbol
	        , company
	        , "NYSE"

	UNION ALL

	select nasdaq.symbol as symbol
	    , nasdaq.company as company_name
	    , "NASDAQ" as market_exchange
	from ds7330_term_raw_data.nasdaq_symbols nasdaq
	group by symbol
	        , company
	        , "NASDAQ"
);

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@@ QUANTITATIVE DATA FOR QUANTITATIVE ANALYSIS @@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
insert into ds7330_term_project.daily( --this has been tested with data 11-2-2019
  Select
  cast(substring(from_unixtime(unix_timestamp(regexp_replace(times, '"',''), 'dd-MMM-yyyy')),0,10) as string) as report_date -- foreign key
  , regexp_replace(symbol, '"','') as symbol -- foreign key
  , volume as trade_volume
  , regexp_replace(market, '"','') as market
  , open_price
  , close_price
  , high_price
  , low_price
  from ds7330_term_raw_data.daily_prices_20_years
  group by
  substring(from_unixtime(unix_timestamp(regexp_replace(times, '"',''), 'dd-MMM-yyyy')),0,10)
  , regexp_replace(symbol, '"','') -- foreign key
  , volume
  , regexp_replace(market, '"','')
  , open_price
  , close_price
  , high_price
  , low_price
);

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
insert into ds7330_term_project.intraday( --this has been tested with data 11-2-2019
	Select
	 regexp_replace(intra.times, '"', '') as report_dtm --primary key
	, trim(substring(regexp_replace(intra.times, '"', ''), 1, 10)) as report_date
    , trim(substring(regexp_replace(intra.times, '"', ''), (length(regexp_replace(intra.times, '"', ''))-1)-6, length(intra.times)))  as report_time -- foreign key
	, regexp_replace(intra.symbol, '"', '') as symbol -- foreign key
	, regexp_replace(intra.market, '"', '') as market
	, intra.volume as trade_volume
	, intra.open as open_price
	, intra.close as close_price
	, intra.high as high_price
	, intra.low as low_price
    , obb.lower_bband_open as open_bollinger_band_lower
	, obb.middle_bband_open as open_bollinger_band_middle
	, obb.upper_bband_open as open_bollinger_band_upper
	, cbb.lower_bband_close as close_bollinger_band_lower
	, cbb.middle_bband_close as close_bollinger_band_middle
	, cbb.upper_bband_close as close_bollinger_band_upper
	, hbb.lower_bband_high as high_bollinger_band_lower
	, hbb.middle_bband_high as high_bollinger_band_middle
	, hbb.upper_bband_high as high_bollinger_band_upper
	, lbb.lower_bband_low as low_bollinger_band_lower
	, lbb.middle_bband_low as low_bollinger_band_middle
	, lbb.upper_bband_low as low_bollinger_band_upper
	, mcdo.macd_open as macd_open
	, mcdo.macd_hist_open as macd_hist_open
	, mcdo.mkacd_signal_open as mkacd_signal_open
	, mcdc.macd_close as macd_close
	, mcdc.macd_hist_close as macd_hist_close
	, mcdc.mkacd_signal_close as mkacd_signal_close
	, mcdh.macd_high as macd_high
	, mcdh.macd_hist_high as macd_hist_high
	, mcdh.mkacd_signal_high as mkacd_signal_high
	, mcdl.macd_low as macd_low
	, mcdl.macd_hist_low as macd_hist_low
	, mcdl.mkacd_signal_low as mkacd_signal_low
	, stoch.slowd as slowd_stochastic
	, stoch.slowk as slowk_stochastic
	, exp.exponential_ma_open as exponential_ma_open
	, exp.exponential_ma_high as exponential_ma_high
	, exp.exponential_ma_low as exponential_ma_low
	, exp.exponential_ma_close as exponential_ma_close
	from ds7330_term_raw_data.intraday_prices_15_min intra
	join (
		  select
		  	times
		  	, real_lower_band as lower_bband_open
		  	, real_middle_band as middle_bband_open
		  	, real_upper_band as upper_bband_open
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.bbands_open_15_min
		  group by times
		  	, real_lower_band
		  	, real_middle_band
		  	, real_upper_band
		  	, symbol
		  	, market
		  ) obb
	on intra.times = obb.times
	and intra.symbol = obb.symbol
	join (
		  select 
		  	times
		  	, real_lower_band as lower_bband_close
		  	, real_middle_band as middle_bband_close
		  	, real_upper_band as upper_bband_close
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.bbands_close_15_min
		  group by times
		  	, real_lower_band
		  	, real_middle_band
		  	, real_upper_band
		  	, symbol
		  	, market
		  ) cbb
	on intra.times = cbb.times
	and intra.symbol = cbb.symbol
	join (
		  select 
		  	times
		  	, real_lower_band as lower_bband_high
		  	, real_middle_band as middle_bband_high
		  	, real_upper_band as upper_bband_high
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.bbands_high_15_min
		  group by times
		  	, real_lower_band
		  	, real_middle_band
		  	, real_upper_band
		  	, symbol
		  	, market
		  ) hbb
	on intra.times = hbb.times
	and intra.symbol = hbb.symbol
	join (
		  select 
		  	times
		  	, real_lower_band as lower_bband_low
		  	, real_middle_band as middle_bband_low
		  	, real_upper_band as upper_bband_low
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.bbands_low_15_min
		  group by times
		  	, real_lower_band
		  	, real_middle_band
		  	, real_upper_band
		  	, symbol
		  	, market
		  ) lbb
	on intra.times = lbb.times
	and intra.symbol = lbb.symbol
	join (
		  select
		  	times
		  	, macd as macd_open
		  	, macd_hist as macd_hist_open
		  	, mkacd_signal as mkacd_signal_open
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.macd_open_15_min
		  group by times
		  	, macd
		  	, macd_hist
		  	, mkacd_signal
		  	, symbol
		  	, market
		  ) mcdo
	on intra.times = mcdo.times
	and intra.symbol = mcdo.symbol
	join (
		  select
		  	times
		  	, macd as macd_close
		  	, macd_hist as macd_hist_close
		  	, mkacd_signal as mkacd_signal_close
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.macd_close_15_min
		  group by times
		  	, macd
		  	, macd_hist
		  	, mkacd_signal
		  	, symbol
		  	, market
		  ) mcdc
	on intra.times = mcdc.times
	and intra.symbol = mcdc.symbol
	join (
		  select
		  	times
		  	, macd as macd_high
		  	, macd_hist as macd_hist_high
		  	, mkacd_signal as mkacd_signal_high
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.macd_high_15_min
		  group by times
		  	, macd
		  	, macd_hist
		  	, mkacd_signal
		  	, symbol
		  	, market
		  ) mcdh
	on intra.times = mcdh.times
	and intra.symbol = mcdh.symbol
	join (
		  select
		  	times
		  	, macd as macd_low
		  	, macd_hist as macd_hist_low
		  	, mkacd_signal as mkacd_signal_low
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.macd_low_15_min
		  group by
		    times
		  	, macd
		  	, macd_hist
		  	, mkacd_signal
		  	, symbol
		  	, market
		  ) mcdl
	on intra.times = mcdl.times
	and intra.symbol = mcdl.symbol
	join (
		  select
		  	times
		  	, slowd
		  	, slowk
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.stochastic_15_min
		  group by
		    times
		  	, slowd
		  	, slowk
		  	, symbol
		  	, market
		  ) stoch
	on intra.times = stoch.times
	and intra.symbol = stoch.symbol
	join (
		  select
		  	times
		  	, exponential_ma_open
		  	, exponential_ma_high
		  	, exponential_ma_low
		  	, exponential_ma_close
		  	, symbol
		  	, market
		  from ds7330_term_raw_data.exp_moving_average_15_min
		  group by
		    times
		  	, exponential_ma_open
		  	, exponential_ma_high
		  	, exponential_ma_low
		  	, exponential_ma_close
		  	, symbol
		  	, market
		  ) exp
	on intra.times = exp.times
	and intra.symbol = exp.symbol
	group by 
	regexp_replace(intra.times, '"', '')
	, trim(substring(regexp_replace(intra.times, '"', ''), 1, 10))
	, trim(substring(regexp_replace(intra.times, '"', ''), (length(regexp_replace(intra.times, '"', ''))-1)-6, length(intra.times)))
	, regexp_replace(intra.symbol, '"', '')
	, regexp_replace(intra.market, '"','')
	, intra.volume
	, intra.open
	, intra.close
	, intra.high
	, intra.low
	, obb.lower_bband_open
	, obb.middle_bband_open
	, obb.upper_bband_open
	, cbb.lower_bband_close
	, cbb.middle_bband_close
	, cbb.upper_bband_close
	, hbb.lower_bband_high
	, hbb.middle_bband_high
	, hbb.upper_bband_high
	, lbb.lower_bband_low
	, lbb.middle_bband_low
	, lbb.upper_bband_low
	, mcdo.macd_open
	, mcdo.macd_hist_open
	, mcdo.mkacd_signal_open
	, mcdc.macd_close
	, mcdc.macd_hist_close
	, mcdc.mkacd_signal_close
	, mcdh.macd_high
	, mcdh.macd_hist_high
	, mcdh.mkacd_signal_high
	, mcdl.macd_low
	, mcdl.macd_hist_low
	, mcdl.mkacd_signal_low
	, stoch.slowd
	, stoch.slowk
	, exp.exponential_ma_open
	, exp.exponential_ma_high
	, exp.exponential_ma_low
	, exp.exponential_ma_close
);

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@@@@@@@@ TWEETS FOR SENTIMENT ANALYSIS @@@@@@@@@@@@@@@@@@@@@@@@@-------
-------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@-------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

insert into ds7330_term_project.twitter_tweet( --this has been tested with data 11-2-2019
  Select
    tweet_id
    , text
    , `date` as report_date
    , `time`  as report_time
    , user_id
    , regexp_replace(symbol, '"','') as symbol
    , tweet_symbol_id as tweet_symbol_id
  from ds7330_term_raw_data.tweet_urls
  group by
    tweet_id
    , text
    , `date`
    , `time`
    , user_id
    , regexp_replace(symbol, '"','')
    , tweet_symbol_id
);

insert into ds7330_term_project.twitter_user( --this has been tested with data 11-2-2019
  Select
    user_id
    , `user`
  from ds7330_term_raw_data.tweet_mentions
  group by
    user_id
    , `user`
);

insert into ds7330_term_project.twitter_tweet_mention( --this has been tested with data 11-2-2019
  Select
    tweet_id
    , user_id
  from ds7330_term_raw_data.tweet_mentions
  group by
    tweet_id
    , user_id
);

insert into ds7330_term_project.twitter_tweet_url( --this has been tested with data 11-2-2019
  Select
    tweet_id
    , url_id
  from ds7330_term_raw_data.tweet_urls
  group by
    tweet_id
    , url_id
);

insert into ds7330_term_project.twitter_tweet_hashtag( --this has been tested with data 11-2-2019
  Select
    tweet_id
    , hashtag_id
  from ds7330_term_raw_data.tweet_hashtags
  group by
    tweet_id
    , hashtag_id
);

insert into ds7330_term_project.twitter_hashtag( --this has been tested with data 11-2-2019
  Select
    hashtag_id
    , hashtag
  from ds7330_term_raw_data.tweet_hashtags
  group by
    hashtag_id
    , hashtag
);

insert into ds7330_term_project.twitter_url( --this has been tested with data 11-2-2019
  Select
    url_id
    , url
  from ds7330_term_raw_data.tweet_urls
  group by
    url_id
    , url
);