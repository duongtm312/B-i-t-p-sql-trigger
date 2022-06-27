create database Shopmanager;
use shopmanager;
create table KhachHang (
MAKH INT PRIMARY KEY,
HOTEN VARCHAR (50),
DCHI VARCHAR (50),
SODT VARCHAR (15) unique,
NGSINH DATETIME,
DOANHSO FLOAT,
NGDK DATETIME
);

CREATE TABLE NHANVIEN (
MANV INT PRIMARY KEY ,
HOTEN VARCHAR (50),
NGVL DATETIME,
SODT VARCHAR (15) unique
);
CREATE table SANPHAM (
MASP INT primary KEY ,
TENSP VARCHAR (50),
DVT VARCHAR (15),
NUOCSX VARCHAR (30),
GIA FLOAT
);
CREATE TABLE HOADON (
SOHD INT primary KEY,
NGHD DATETIME,
MAKH INT,
MANV INT,
TRIGIA FLOAT,
foreign key (MAKH) references KHACHHANG(MAKH),
foreign key (MANV) references NHANVIEN(MANV)
);
CREATE TABLE CTHD (
SOHD int,
MASP INT,
SL INT,
foreign key (SOHD) references HOADON(SOHD),
foreign key (MASP) references SANPHAM(MASP),
primary key (SOHD,MASP)
);
insert into khachhang values (1,'Trần Minh Dương','Hà Nội','0111111111','1999/3/12',0,'2022/6/26'),
								(2,'Bùi Công Anh','Hà Nội','0222222222','1997/1/12',0,'2022/6/25'),
                                (3,'Lê Văn A','Hà Nam','03332222222','1980/3/8',0,'2022/5/21'),
                                 (4,'Nguyễn Thị B','Hà Nam','04442222222','1995/7/21',0,'2022/3/12'),
                                 (5,'Phan Văn TƯởng','Nam Định','055542222','1998/5/1',0,'2022/3/23');
insert into nhanvien values (1,'Nguyễn Văn A','2021/07/30','0123456789'),
							(2,'Nguyễn Văn B','2021/05/25','0234567891'),
                            (3,'Nguyễn Văn C','2021/04/20','0345678912');
insert into sanpham values (1,'Bánh mỳ','chiếc','việt nam','10'),
						   (2,'Bún chả','bát','việt nam','30'),
                           (3,'Bún đậu','mẹt','việt nam','25'),
                           (4,'Mỳ ý','đĩa','ý','50');
insert into hoadon values (1,'2022/05/25',1,2,0),
						  (2,'2021/05/25',4,3,0),
                          (3,'2022/10/25',3,1,0),
						  (4,'2006/07/25',1,2,0),
						  (5,'2006/01/20',2,3,0),
                          (6,'2022/10/25',3,1,0);
DELIMITER $$
CREATE TRIGGER insertcthd
 After insert on cthd
 FOR EACH ROW
BEGIN
	update hoadon set TRIGIA =TRIGIA + (new.SL*(select GIA from SANPHAM where MASP = new.MASP ))where SOHD = new.SOHD ;
END
$$

DELIMITER $$
CREATE TRIGGER updatedoanhthu
 After update on hoadon
 FOR EACH ROW
BEGIN
	update khachhang set DOANHSO =DOANHSO + new.TRIGIA where MAKH = new.MAKH;
END
$$


insert into cthd values (1,2,3),
						(1,1,5),
                        (2,2,3),
                        (2,3,5),
                        (3,2,1),
						(4,2,10),
						(5,1,5),
						(6,3,1);
-- Cau1
select distinct sp.TENSP as 'Sản phẩm'
from hoadon HD join cthd CT on HD.sohd = CT.sohd join sanpham sp on sp.MASP = CT.MASP
where year(HD.nghd) = 2006  ;
-- Cau2
select max(hoadon.trigia) as 'Bill Max', min(hoadon.trigia) as 'Bill Min'
from hoadon; 
-- Cau3
select avg(TRIGIA) as 'Hóa Đơn Trung Bình' from hoadon where year(nghd) = 2006;
-- Cau4
select sum(TRIGIA) as 'Doanh thu' from hoadon where year(nghd) = 2006;
-- Cau5
select max(TRIGIA) as 'Doanh thu' from hoadon where year(nghd) = 2006;
-- Cau6
CREATE VIEW hoadon_2006 AS
select kh.HOTEN ,TRIGIA from HOADON hd join KhachHang kh on hd.MAKH = kh.MAKH where year(nghd) = 2006;
select HOTEN from  hoadon_2006 where TRIGIA = (select max(TRIGIA) from hoadon_2006);

-- Cau7
select KH.makh,KH.hoten,KH.doanhso
from khachhang kh
order by kh.doanhso desc
limit 3;
-- Cau8
select masp, tensp, gia
from sanpham
where gia >= (
select distinct gia from sanpham
order by gia desc
limit 2,1
);
-- Cau9
select masp, tensp, gia
from sanpham
where nuocsx like 'ý' and gia >= (
select distinct gia from sanpham
order by gia desc
limit 2,1
);
-- Cau10
-- Cau11
Select *, rank() over(order by doanhso DESC) as ranking from khachhang limit 3;
-- Cau12
select count(masp) 'Số sản phẩm'
from sanpham
where nuocsx like 'ý' ;
-- Cau13
select nuocsx,count(masp) 'Số sản phẩm'
from sanpham
group by nuocsx ;
-- Cau14
select nuocsx , min(gia) as 'gia sp min', max(gia) as 'gia sp max', avg(gia) as 'gia sp avg' 
from sanpham
group by nuocsx;
-- Cau15
select nghd as 'Ngày', sum(trigia) as 'Doanh thu'
from hoadon
group by nghd
order by nghd;
-- Cau16
select count(cthd.sl) ' Số lượng bán ra'
from cthd join hoadon on hoadon.sohd = cthd.sohd
where month(nghd) = 10 and year(nghd) = 2006;
-- Cau17
create view doanhthuthang2006 as
select month(nghd) as 'tháng', sum(trigia) as 'doanhthu'
from hoadon
where year(nghd) = 2006
group by month(nghd)
order by month(nghd);
select * from doanhthuthang2006;
-- Cau18
select hoadon.sohd count(MASP) from hoadon join cthd on cthd.sohd = hoadon.sohd
group by hoadon.sohd having count(cthd.masp) = 3 ;
-- Cau19
select hoadon.sohd , count(cthd.masp) as 'so sp'
from hoadon join cthd on cthd.sohd = hoadon.sohd join sanpham on sanpham.masp = cthd.masp
where sanpham.nuocsx = 'việt nam'
group by hoadon.sohd
having count(cthd.masp) = 3 ;
-- Cau20
select khachhang.makh, khachhang.hoten,count(hoadon.sohd) from khachhang join hoadon on  hoadon.makh = khachhang.makh group by khachhang.makh 
having count(hoadon.sohd)= (select count(hoadon.sohd) from khachhang join hoadon on  hoadon.makh = khachhang.makh group by khachhang.makh order by count(hoadon.sohd) desc limit 1);
-- Cau21
select * from doanhthuthang2006 where doanhthu = (select max(doanhthu) from doanhthuthang2006);
-- Cau22
select sanpham.masp, sanpham.tensp, count(cthd.sl) as 'số lượng bán ra'
from sanpham join cthd on cthd.masp = sanpham.masp join hoadon on hoadon.sohd = cthd.sohd 
where year(hoadon.nghd) = 2006
group by sanpham.masp
having count(cthd.sl) = (
select count(cthd.sl)
from sanpham join cthd on cthd.masp = sanpham.masp join hoadon on hoadon.sohd = cthd.sohd 
where year(hoadon.nghd) = 2006
group by sanpham.masp
order by count(cthd.sl)
limit 1);
-- Cau23
