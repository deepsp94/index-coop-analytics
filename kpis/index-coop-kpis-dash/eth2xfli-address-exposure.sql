-- https://duneanalytics.com/queries/77468

WITH transfers AS (

  SELECT
    tr."from" AS address,
    -tr.value / 1e18 AS amount,
    date_trunc('day', evt_block_time) AS evt_block_day,
    'transfer' AS type,
    evt_tx_hash
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

  UNION ALL

  SELECT
    tr."to" AS address,
    tr.value / 1e18 AS amount,
    date_trunc('day', evt_block_time) AS evt_block_day,
    'transfer' AS type,
    evt_tx_hash
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

),

balancer_add AS (

  SELECT
    tr."from" AS address,
    tr.value / 1e18 AS amount,
    date_trunc('day', evt_block_time) AS evt_block_day,
    'balancer_add' AS type,
    evt_tx_hash
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
    AND evt_tx_hash IN (
    
        SELECT
            evt_tx_hash
        FROM balancer."BPool_evt_LOG_JOIN"
        WHERE "tokenIn" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
        
    )

),



balancer_remove AS (

  SELECT
    tr."to" AS address,
    -tr.value / 1e18 AS amount,
    date_trunc('day', evt_block_time) AS evt_block_day,
    'balancer_remove' AS type,
    evt_tx_hash
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
    AND evt_tx_hash IN (
    
        SELECT
            evt_tx_hash
        FROM balancer."BPool_evt_LOG_EXIT"
        WHERE "tokenOut" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
        
    )
    
),

uniswap_add AS (

  SELECT
    "to" AS address,
    ("output_amountToken"/1e18) AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_addLiquidityETH"
  WHERE token = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN ("output_amountA"/1e18)
      WHEN "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN ("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router01_call_addLiquidity"
  WHERE "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
    OR "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN ("output_amountA"/1e18)
      WHEN "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN ("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_addLiquidity"
  WHERE "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
    OR "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

),

uniswap_remove AS (

  SELECT
    "to" AS address,
    -("output_amountToken"/1e18) AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidityETHWithPermit"
  WHERE token = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

  UNION ALL

  SELECT
    "to" AS address,
    -("output_amountToken"/1e18) AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidityETH"
  WHERE token = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router01_call_removeLiquidity"
  WHERE "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
    OR "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidity"
  WHERE "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
    OR "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('day', call_block_time) AS evt_block_day,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidityWithPermit"
  WHERE "tokenA" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
    OR "tokenB" = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'

),

uniswapv3_pool as (
  select
              pool,
              token0,
              tok0.symbol as symbol0,
              tok0.decimals as decimals0,
              token1,
              tok1.symbol as symbol1,
              tok1.decimals as decimals1

  from        uniswap_v3."Factory_evt_PoolCreated" pool
  
  inner join  erc20."tokens" tok0 
  on          pool.token0 = tok0.contract_address
  
  inner join  erc20."tokens" tok1 
  on          pool.token1 = tok1.contract_address

  where       token0 = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
  or          token1 = '\xaa6e8127831c9de45ae56bb1b0d4d4da6e5665bd'
),

uniswapv3_add as (

SELECT
	"from" as address,
	case 
    when symbol0 = 'ETH2x-FLI' then amount0 / (10^decimals0) 
    when symbol1 = 'ETH2x-FLI' then amount1 / (10^decimals1) 
  end as amount,
	date_trunc('day', block_time) AS evt_block_day,
	'uniswapv3_add' as type,
	hash as evt_tx_hash
	
	FROM uniswap_v3."Pair_evt_Mint" m
  INNER JOIN uniswapv3_pool p
  on p.pool = m.contract_address
	LEFT JOIN ethereum."transactions" tx ON m.evt_tx_hash = tx.hash
	WHERE tx.block_time > '5/4/21'
	
),


uniswapv3_remove as (

SELECT
	"from" as address,
	case 
    when symbol0 = 'ETH2x-FLI' then -amount0 / (10^decimals0) 
    when symbol1 = 'ETH2x-FLI' then -amount1 / (10^decimals1) 
  end as amount,
	date_trunc('day', block_time) AS evt_block_day,
	'uniswapv3_remove' as type,
	hash as evt_tx_hash
	
	FROM uniswap_v3."Pair_evt_Burn" m
  INNER JOIN uniswapv3_pool p
  on p.pool = m.contract_address
	LEFT JOIN ethereum."transactions" tx ON m.evt_tx_hash = tx.hash
	WHERE tx.block_time > '5/4/21'
),


lp AS (

SELECT * FROM uniswap_add

UNION ALL

SELECT * FROM uniswap_remove

UNION ALL

SELECT * FROM balancer_add

UNION ALL

SELECT * FROM balancer_remove

union all

select * from uniswapv3_add

union all

select * from uniswapv3_remove

),

contracts AS (

  SELECT
    address,
    "type"
  FROM labels.labels
  WHERE "type" = 'contract_name'

),

liquidity_providing AS (

  SELECT
    l.*,
    CASE c.type
      WHEN 'contract_name' THEN 'contract'
      ELSE 'non-contract'
    END AS contract
  FROM lp l
  LEFT JOIN contracts c ON l.address = c.address

),

moves AS (

  SELECT
    *
  FROM transfers

  UNION ALL

  SELECT
    address,
    amount,
    evt_block_day,
    type,
    evt_tx_hash
  FROM liquidity_providing
  WHERE contract = 'non-contract'

),

exposure AS (

    SELECT
      m.address,
      evt_block_day,
      sum(amount) AS exposure
    FROM moves m
    LEFT JOIN contracts c ON m.address = c.address
    WHERE c.type IS NULL
      AND m.type IN ('mint', 'burn', 'transfer',
      'uniswap_add', 'uniswap_remove', 'balancer_add', 'balancer_remove',
	  'uniswapv3_add', 'uniswapv3_remove')
    GROUP BY 1, 2
    ORDER BY 1, 2

),

address_by_date  AS (

    SELECT
        DISTINCT
        t1.address,
        t2.evt_block_day
    FROM exposure t1
    CROSS JOIN (
        SELECT
            DISTINCT(evt_block_day)
        FROM exposure
    ) t2

),

temp AS (

  SELECT
    a.address,
    a.evt_block_day,
    CASE e.exposure
        WHEN NULL THEN 0
        ELSE e.exposure
    END AS exposure
  FROM address_by_date a
  LEFT JOIN exposure e ON a.address = e.address AND a.evt_block_day = e.evt_block_day

),

address_over_time AS (

    SELECT
        address,
        evt_block_day,
        sum(exposure) OVER (PARTITION BY address ORDER BY evt_block_day ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exposure
    FROM temp

)

SELECT
    evt_block_day,
    COUNT(DISTINCT(address))
FROM address_over_time
WHERE exposure > 0
GROUP BY 1
