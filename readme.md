# Analisis dan Rekomendasi Film dengan Neo4j

Kumpulan query Cypher ini menggunakan data pengguna, film, dan rating untuk:

- Membuat rekomendasi film berdasarkan film yang disukai bersama.
- Mengelompokkan pengguna menggunakan algoritma komunitas Louvain dan Leiden.

## Isi file

### `community_detection.cypher`

Membuat rekomendasi film dengan pendekatan *item-based collaborative filtering*. Query mencari pengguna yang memberi rating minimal `4.0` pada film **Toy Story (1995)** dan film lainnya, lalu memberi peringkat pada film berdasarkan jumlah pengguna yang sama-sama menyukainya.

Query dalam file ini dijalankan berurutan untuk:

1. Menampilkan maksimal 10 rekomendasi beserta skor kecocokan.
2. Menyimpan rekomendasi sebagai relasi `RECOMMENDS` dengan properti `score`.
3. Menampilkan relasi rekomendasi tersebut sebagai graf.

### `louvain_leiden.cypher`

Menyiapkan dan menganalisis graf rating pengguna-film:

1. Mengubah properti `rating` pada relasi `RATED` menjadi tipe numerik.
2. Membuat proyeksi GDS bernama `movieGraph`, dengan relasi rating diperlakukan sebagai graf tak berarah.
3. Menjalankan Louvain untuk melihat komunitas pengguna, menyimpan hasilnya pada properti `louvainGroup`, dan menampilkan ringkasan atau contoh anggota komunitas.
4. Menjalankan Leiden untuk melihat komunitas pengguna dan menyimpan hasilnya pada properti `leidenGroup`.

## Cara menjalankan

1. Buka database Neo4j yang sudah berisi data dengan bentuk seperti di atas.
2. Jalankan isi `louvain_leiden.cypher` di Neo4j Browser atau Neo4j Workspace. Query pada bagian persiapan dan pembuatan proyeksi perlu dijalankan sebelum query algoritma.
3. Jalankan bagian Louvain dan/atau Leiden sesuai analisis yang dibutuhkan.
4. Jalankan `community_detection.cypher` untuk membuat dan menyimpan rekomendasi.

Jalankan query secara berurutan; setiap query yang dipisahkan oleh titik koma adalah satu statement. Jika proyeksi `movieGraph` sudah ada, hapus proyeksi tersebut sebelum menjalankan ulang bagian pembuatan graf, misalnya:

```cypher
CALL gds.graph.drop('movieGraph', false);
```

Menjalankan query penyimpanan akan mengubah database: Louvain dan Leiden menulis properti pada node dalam proyeksi `movieGraph` (baik `User` maupun `Movie`), sedangkan query rekomendasi membuat atau memperbarui relasi `RECOMMENDS`.

## Batasan analisis

### Rekomendasi film

- **Film acuan tetap.** Query hanya mencari rekomendasi berdasarkan judul yang mengandung `Toy Story (1995)`. Hasilnya merupakan rekomendasi umum untuk film acuan tersebut, bukan rekomendasi personal untuk pengguna tertentu.
- **Ambang rating tetap.** Rating minimal `4.0` dipakai untuk film acuan dan film kandidat. Rating yang lebih rendah tidak dihitung, dan rating 4 tidak dibedakan dari rating 5.
- **Skor adalah hitungan mentah.** `count(*)` menghitung baris kecocokan, bukan prediksi rating, probabilitas pengguna menyukai film, ataupun ukuran kemiripan yang dinormalisasi. Jika ada beberapa relasi rating untuk pasangan pengguna-film yang sama, skor juga dapat menghitungnya lebih dari sekali.
- **Bias popularitas.** Film yang dinilai oleh banyak pengguna lebih berpeluang mendapatkan skor tinggi. Karena skor tidak dinormalisasi terhadap jumlah pengguna yang menilai tiap film, skor tinggi belum tentu menunjukkan kemiripan preferensi yang kuat. Cosine similarity atau Jaccard similarity dapat dipertimbangkan sebagai pengembangan.
- **Cold start.** Film baru yang belum memiliki rating tidak memiliki pola rating bersama untuk dihitung, sehingga query ini tidak dapat merekomendasikannya.
- **Maksimal 10 kandidat.** Query hanya menampilkan atau menyimpan hingga 10 pasangan film dengan skor tertinggi; jika skor sama, urutan antarfilm dengan skor sama tidak ditentukan secara eksplisit.
- **Relasi hasil bukan data rating asli.** `RECOMMENDS` adalah relasi analisis yang dibuat dari pola rating, bukan relasi `RATED`. Properti `score` menyimpan hitungan kecocokan dan dapat diperbarui ketika query simpan dijalankan kembali.

### Community detection

- Proyeksi `movieGraph` mencakup node `User` dan `Movie`, dan relasi `RATED` diperlakukan sebagai tak berarah. Karena itu, algoritma bekerja pada graf bipartit gabungan, bukan hanya pada node pengguna.
- Properti `rating` dimasukkan ke proyeksi, tetapi pemanggilan Louvain dan Leiden tidak menetapkan `relationshipWeightProperty`. Dengan demikian, nilai rating tidak digunakan sebagai bobot dalam perhitungan komunitas.
- Query `stream` hanya memfilter hasil yang ditampilkan menjadi node `User`; algoritma tetap dijalankan pada seluruh node dalam proyeksi. Hasil `write` juga ditulis untuk node-node dalam proyeksi, termasuk `Movie`.
- Label komunitas adalah hasil pengelompokan, bukan skor rekomendasi. Jumlah atau ID komunitas saja tidak cukup untuk menyimpulkan bahwa Louvain atau Leiden lebih baik; diperlukan evaluasi yang sesuai.

## Catatan hasil

- `Skor_Kecocokan` adalah jumlah baris kecocokan rating minimal `4.0` pada film sumber dan film rekomendasi. Jika tiap pasangan pengguna-film hanya memiliki satu relasi `RATED`, nilai ini sama dengan jumlah pengguna yang cocok.
- `louvainGroup` dan `leidenGroup` adalah properti label komunitas hasil algoritma. ID komunitas dapat berbeda ketika algoritma dijalankan ulang.
- Query contoh visualisasi Louvain menggunakan ID komunitas `1351`, sedangkan contoh Leiden menggunakan ID `0`. Ganti ID tersebut sesuai hasil pada database Anda.