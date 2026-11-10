// persiapan
MATCH ()-[r:RATED]-()
SET r.rating = toFloat(r.rating)

// buat proyeksi graf

CALL gds.graph.project(
  'movieGraph',
  ['User', 'Movie'],
  {
    RATED: {
      type: 'RATED',
      orientation: 'UNDIRECTED',
      properties: 'rating'
    }
  }
)


// Louvain

// buat graf louvain
CALL gds.louvain.stream('movieGraph')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS node, communityId
WHERE node:User
RETURN node.userId AS UserId, communityId AS Kelompok_Louvain
ORDER BY Kelompok_Louvain ASC
LIMIT 30

// menyimpan graf louvain
CALL gds.louvain.write('movieGraph', { writeProperty: 'louvainGroup' })

// menampilkan graf 
MATCH (u:User)
WHERE u.louvainGroup IS NOT NULl
RETURN u.louvainGroup AS Nomor_Kelompok, COUNT(*) AS Jumlah_Anggota
ORDER BY Jumlah_Anggota DESC
LIMIT 10

MATCH (u:User {louvainGroup: 1351})-[r:RATED]->(m:Movie)
RETURN u, r, m
LIMIT 50


// Leiden

// buat graf leiden
CALL gds.leiden.stream('movieGraph')
YIELD nodeId, communityId
WITH gds.util.asNode(nodeId) AS node, communityId
WHERE node:User
RETURN node.userId AS UserId, communityId AS Kelompok_Leiden
ORDER BY Kelompok_Leiden ASC
LIMIT 30

// menyimpan graf leiden
CALL gds.leiden.write('movieGraph', { writeProperty: 'leidenGroup' })


// menampilkan graf
MATCH (u:User {leidenGroup: 0})-[r:RATED]->(m:Movie)
RETURN u, r, m
LIMIT 50