CREATE TEMPORARY TABLE eta AS
SELECT id_cliente,
       TIMESTAMPDIFF(YEAR, data_nascita, CURDATE()) AS eta
FROM cliente;

CREATE TEMPORARY TABLE transazioni_uscita AS
SELECT DISTINCT c.id_cliente,
       COUNT(*) AS num_transazioni_uscita
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'
GROUP BY c.id_cliente
ORDER BY c.id_cliente;

CREATE TEMPORARY TABLE transazioni_entrata AS
SELECT DISTINCT c.id_cliente,
       COUNT(*) AS num_transazioni_entrata
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'
GROUP BY c.id_cliente
ORDER BY c.id_cliente;

CREATE TEMPORARY TABLE importo_uscita_tutti_conti AS
SELECT DISTINCT c.id_cliente,
       SUM(t.importo) AS importo_uscita_tutti_conti
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-'
GROUP BY c.id_cliente
ORDER BY c.id_cliente;

CREATE TEMPORARY TABLE importo_entrata_tutti_conti AS
SELECT DISTINCT c.id_cliente,
       SUM(t.importo) AS importo_entrata_tutti_conti
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+'
GROUP BY c.id_cliente
ORDER BY c.id_cliente;

CREATE TEMPORARY TABLE num_conti AS
SELECT DISTINCT id_cliente,
       COUNT(id_conto) AS num_conti_posseduti
FROM conto co
GROUP BY co.id_cliente
ORDER BY co.id_cliente;

CREATE TEMPORARY TABLE num_conti_per_tipologia AS
SELECT DISTINCT c.id_cliente,
       COUNT(CASE WHEN tc.id_tipo_conto = 0 THEN 1 END) AS conti_base,
       COUNT(CASE WHEN tc.id_tipo_conto = 1 THEN 1 END) AS conti_business,
       COUNT(CASE WHEN tc.id_tipo_conto = 2 THEN 1 END) AS conti_privati,
       COUNT(CASE WHEN tc.id_tipo_conto = 3 THEN 1 END) AS conti_famiglie
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
GROUP BY c.id_cliente;

CREATE TEMPORARY TABLE num_transazioni_uscita_per_tipologia AS
SELECT DISTINCT c.id_cliente,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Acquisto su Amazon' THEN 1 ELSE 0 END) AS acquisto_amazon,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Rata mutuo' THEN 1 ELSE 0 END) AS rata_mutuo,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Hotel' THEN 1 ELSE 0 END) AS hotel,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Biglietto aereo' THEN 1 ELSE 0 END) AS biglietto_aereo,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Supermercato' THEN 1 ELSE 0 END) AS supermercato
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '-' -- Solo transazioni in uscita
GROUP BY c.id_cliente
ORDER BY c.id_cliente;

CREATE TEMPORARY TABLE num_transazioni_entrata_per_tipologia AS
SELECT DISTINCT c.id_cliente,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Stipendio' THEN 1 ELSE 0 END) AS stipendio,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Pensione' THEN 1 ELSE 0 END) AS pensione,
       COUNT(CASE WHEN tt.desc_tipo_trans = 'Dividendi' THEN 1 ELSE 0 END) AS dividendi
FROM cliente c
JOIN conto co ON c.id_cliente = co.id_cliente
JOIN transazioni t ON co.id_conto = t.id_conto
JOIN tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE tt.segno = '+' -- Solo transazioni in entrata
GROUP BY c.id_cliente
ORDER BY  c.id_cliente;

CREATE TEMPORARY TABLE importo_uscita_per_tipologia AS
SELECT DISTINCT
    c.id_cliente,
    tc.desc_tipo_conto,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Acquisto su Amazon' THEN t.importo ELSE 0 END) AS importo_acquisto_amazon,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Rata mutuo' THEN t.importo ELSE 0 END) AS importo_rata_mutuo,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Hotel' THEN t.importo ELSE 0 END) AS importo_hotel,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Biglietto aereo' THEN t.importo ELSE 0 END) AS importo_biglietto_aereo,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Supermercato' THEN t.importo ELSE 0 END) AS importo_supermercato
FROM
    cliente c
JOIN
    conto co ON c.id_cliente = co.id_cliente
JOIN
    tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
JOIN
    transazioni t ON co.id_conto = t.id_conto
JOIN
    tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE
    tt.segno = '-' 
GROUP BY
    c.id_cliente, tc.desc_tipo_conto
ORDER BY
    c.id_cliente;

CREATE TEMPORARY TABLE importo_entrata_per_tipologia AS
SELECT DISTINCT
    c.id_cliente,
    tc.desc_tipo_conto,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Stipendio' THEN t.importo ELSE 0 END) AS importo_stipendio,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Pensione' THEN t.importo ELSE 0 END) AS importo_pensione,
    SUM(CASE WHEN tt.desc_tipo_trans = 'Dividendi' THEN t.importo ELSE 0 END) AS importo_dividendi
FROM
    cliente c
JOIN
    conto co ON c.id_cliente = co.id_cliente
JOIN
    tipo_conto tc ON co.id_tipo_conto = tc.id_tipo_conto
JOIN
    transazioni t ON co.id_conto = t.id_conto
JOIN
    tipo_transazione tt ON t.id_tipo_trans = tt.id_tipo_transazione
WHERE
    tt.segno = '+' -- Solo transazioni in entrata
GROUP BY
    c.id_cliente, tc.desc_tipo_conto
ORDER BY
    c.id_cliente;


CREATE TEMPORARY TABLE tabella_aggregata AS
SELECT
    e.id_cliente,
    e.eta,
    tu.num_transazioni_uscita,
    te.num_transazioni_entrata,
    ROUND(iutc.importo_uscita_tutti_conti, 2) AS importo_uscita_tutti_conti,
    ROUND(ietc.importo_entrata_tutti_conti, 2) AS importo_entrata_tutti_conti,
    nc.num_conti_posseduti,
    nctp.conti_base AS num_conti_base,
    nctp.conti_business AS num_conti_business,
    nctp.conti_privati AS num_conti_privati,
    nctp.conti_famiglie AS num_conti_famiglie,
    ntut.acquisto_amazon AS num_transazioni_uscita_acquisto_amazon,
    ntut.rata_mutuo AS num_transazioni_uscita_rata_mutuo,
    ntut.hotel AS num_transazioni_uscita_hotel,
    ntut.biglietto_aereo AS num_transazioni_uscita_biglietto_aereo,
    ntut.supermercato AS num_transazioni_uscita_supermercato,
    ntet.stipendio AS num_transazioni_entrata_stipendio,
    ntet.pensione AS num_transazioni_entrata_pensione,
    ntet.dividendi AS num_transazioni_entrata_dividendi,
    ROUND(iupt.importo_acquisto_amazon, 2) AS importo_uscita_acquisto_amazon,
    ROUND(iupt.importo_rata_mutuo, 2) AS importo_uscita_rata_mutuo,
    ROUND(iupt.importo_hotel, 2) AS importo_uscita_hotel,
    ROUND(iupt.importo_biglietto_aereo, 2) AS importo_uscita_biglietto_aereo,
    ROUND(iupt.importo_supermercato, 2) AS importo_uscita_supermercato,
    ROUND(iept.importo_stipendio, 2) AS importo_entrata_stipendio,
    ROUND(iept.importo_pensione, 2) AS importo_entrata_pensione,
    ROUND(iept.importo_dividendi, 2) AS importo_entrata_dividendi
FROM
    eta e
LEFT JOIN
    num_conti nc ON e.id_cliente = nc.id_cliente
LEFT JOIN
    num_conti_per_tipologia nctp ON e.id_cliente = nctp.id_cliente
LEFT JOIN
    transazioni_uscita tu ON e.id_cliente = tu.id_cliente
LEFT JOIN
    transazioni_entrata te ON e.id_cliente = te.id_cliente
LEFT JOIN
    importo_uscita_tutti_conti iutc ON e.id_cliente = iutc.id_cliente
LEFT JOIN
    importo_entrata_tutti_conti ietc ON e.id_cliente = ietc.id_cliente
LEFT JOIN
    num_transazioni_uscita_per_tipologia ntut ON e.id_cliente = ntut.id_cliente
LEFT JOIN
    num_transazioni_entrata_per_tipologia ntet ON e.id_cliente = ntet.id_cliente
LEFT JOIN
    importo_uscita_per_tipologia iupt ON e.id_cliente = iupt.id_cliente
LEFT JOIN
    importo_entrata_per_tipologia iept ON e.id_cliente = iept.id_cliente;
