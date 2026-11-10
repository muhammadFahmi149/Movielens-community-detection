// Collaborative Filtering item based
MATCH (m1:Movie)
WHERE m1.title CONTAINS 'Toy Story (1995)'
MATCH (m1)<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE r1.rating >= 4.0 AND r2.rating >= 4.0 AND m1 <> m2
RETURN m2.title AS Film_Rekomendasi, count(*) AS Skor_Kecocokan
ORDER BY Skor_Kecocokan DESC
LIMIT 10;

// simpan hasil sebagai relasi
MATCH (m1:Movie) WHERE m1.title CONTAINS 'Toy Story (1995)'
MATCH (m1)<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE r1.rating >= 4.0 AND r2.rating >= 4.0 AND m1 <> m2
WITH m1, m2, count(*) AS skor
ORDER BY skor DESC
LIMIT 10
MERGE (m1)-[s:RECOMMENDS]->(m2)
SET s.score = skor;

// tampilkan graf
MATCH p=(m1:Movie)-[s:RECOMMENDS]->(m2:Movie)
WHERE m1.title CONTAINS 'Toy Story (1995)'
RETURN p;