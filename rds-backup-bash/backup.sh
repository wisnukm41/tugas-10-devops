#!/bin/bash

#Variable yang akan digunakan
BACKUP_S3PATH="s3://your-bucket-name" #path ke S3 Bucket
BACKUP_DATE="backup_$(date +%Y-%m-%d)" #nama file backup
DELETE_AFTER_DAYS=7 #variable untuk fungsi menghapus file backup

#mulai dapatkan data dari database
#opsi -N -r -e -s disini sebagai flag agar hasil dari cmd show databases lebih bersih dan dapat langsung digunakan oleh for loop
#grep -v disini digunakan untuk meng exclude beberpa tabel bawaan dari relational database
for db in $(mysql -N -r -e -s 'show databases' | grep -v information_schema | grep -v performance_schema | grep -v mysql | grep -v innodb); do
    echo "Creating DB Backup: $db"
    #proses utama pembackupan, pastikan s3cmd dan mysqldump sudah terinstall di sistem operasi yg digunakan dgn cara apt update dan apt install s3cmd
    #setiap db disini diilustrasikan dgn variable $db, yang akan dibuat dumpnya dgn fungsi cmd mysqldump
    #hasil dumpnya akan dikompress dgn gzip(optional) lalu akan dipindahkan ke bucker s3 dalam forder date dan nama yang sesuai
    /usr/bin/mysqldump "$db" | /bin/gzip | /usr/bin/s3cmd put - "$BACKUP_S3PATH"/"$BACKUP_DATE"/"$db".sql.gz >/dev/null 2>&1
done

# ini adalah fungsi untuk delete dari file yang telah terupload sebelumnya, yg harus diperhatikan adalah -type f disini hanya untuk mengambil file
# -name disini hanya menemukan file dgn ekstensi tertentu, lalu -mtime itu tanggal terakhir dimodifikasi, yang jika ditemukan maka akan di -exec dgn s3cmd delete
find "$BACKUP_S3PATH" -type f -name "*.sql.gz" -mtime +$DELETE_AFTER_DAYS -exec /usr/bin/s3cmd delete {} \;
