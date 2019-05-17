create database QLDulich
go
use QLDulich
--create tables--
----------------

create table TINH
(
	matinh int primary key,
	tentinh nchar(20)
)

create table NGANSACH
(
	matinh int,
	nam int,
	sotien money,
	primary key (matinh, nam)
)

create table DIADANH
(
	ma_dd char(10) primary key,
	ten_dd nvarchar(50) unique,
	matinh	int
)

create table HOATDONG
(
	ma_dd char(10),
	nam int,
	stt_hd int,
	ten_hd nvarchar(50),
	sotien money
	primary key (ma_dd, nam, stt_hd)
)

--add constraint--
------------------

alter table DIADANH
	add constraint fk_diadanh_tinh
	foreign key (matinh) references TINH(matinh)

alter table HOATDONG
	add constraint fk_hoatdong_diadanh
	foreign key (ma_dd) references DIADANH(ma_dd)

alter table NGANSACH
	add constraint fk_ngansach_tinh
	foreign key (matinh) references TINH(matinh)

alter table HOATDONG
	add constraint check_hoatdong_nam
	check (nam in (2017, 2018))

alter table NGANSACH 
	add constraint check_ngansach_nam
	check (nam in (2017, 2018))

--trigger and procedure--
-------------------------
go

create trigger tg_ngansach_hoatdong
on hoatdong
for update, insert
as
if update(sotien)
begin
	if exists (select * from inserted i
				where 
					(select sum(h.sotien) from hoatdong h
					where h.ma_dd in 
								(select d.ma_dd from diadanh d 
								where d.matinh = (select d2.matinh from diadanh d2 
												where d2.ma_dd = i.ma_dd)
								)
							and h.nam = i.nam
					)
					>
					(select sotien from ngansach n
					where n.matinh = (select d.matinh from diadanh d 
										where d.ma_dd = i.ma_dd)
							and n.nam = i.nam
					)
				)
	begin
		raiserror(N'Tỉnh không đủ ngân sách để cấp cho hoạt động này', 16, 1)
		rollback
	end
end
go

--procedure for task 1
create procedure sp_task1 @ma_dd char(10), @nam int
as
	select d.ten_dd, t.tentinh, sum(h.sotien) as N'Kinh phí'
	from (tinh t join diadanh d on (t.matinh = d.matinh)) join hoatdong h on (d.ma_dd = h.ma_dd)
	where h.nam = @nam and h.ma_dd = @ma_dd
	group by d.ten_dd, t.tentinh
go
--exec sp_task1 'VHL', 2017

insert into TINH
values
	(54, N'Quảng Ngãi'),
	(23, N'Hà Nội'),
	(30, N'Quảng Ninh'),
	(33, N'Quảng Nam')

insert into DIADANH
values 
	('TBTD', N'Thạch Bích Tà Dương', 54),
	('CLCT', N'Cổ Lũy Cô Thôn', 54),
	('PCHA', N'Phố Cổ Hội An', 33),
	('CLC', N'Cù Lao Chàm', 33),
	('VHL', N'Vịnh Hạ Long', 30),
	('DTC', N'Đảo Tuần Châu', 30),
	('HHK', N'Hồ Hoàn Kiếm', 23),
	('CMC', N'Chùa Một Cột', 23),
	('LB', N'Lăng Bác', 23)

insert into NGANSACH
values 
	(54, 2017, 35),
	(54, 2018, 30),
	(23, 2017, 30),
	(23, 2018, 30),
	(30, 2017, 40),
	(30, 2018, 35),
	(33, 2017, 20),
	(33, 2018, 30)

insert into HOATDONG
values
	('TBTD', 2017, 1, N'Nạo vét sông', 3),
	('TBTD', 2017, 2, N'Nạo vét sông lần 2', 4),
	('TBTD', 2018, 1, N'Đổ nước vô sông', 3),
	('TBTD', 2018, 2, N'Lọc nước sông', 5),
	('CLCT', 2017, 1, N'Chặt tre', 6),
	('CLCT', 2017, 2, N'Chặt tre lần 2', 5),
	('CLCT', 2018, 1, N'Trồng tre', 7),
	('CLCT', 2018, 2, N'Trồng nhiều tre', 7),
	('PCHA', 2017, 1, N'Xây vincom', 5),
	('PCHA', 2018, 1, N'Đập vincom', 5),
	('CLC', 2017, 1, N'Thả cá vô cù lao', 6),
	('CLC', 2018, 1, N'Bắt cá trong cù lao', 5),
	('VHL', 2017, 1, N'Làm phim king kong', 10),
	('VHL', 2018, 1, N'Tiếp tục làm phim king kong',8),
	('DTC', 2018, 1, N'Cải tạo đảo để chơi PUBG', 8),
	('HHK', 2017, 1, N'Rèn kiếm', 5),
	('HHK', 2018, 1, N'Trả kiếm', 5),
	('CMC', 2017, 1, N'Xây thêm cột', 6),
	('CMC', 2018, 1, N'Gỡ mấy cây cột mới xây', 7),
	('LB', 2018, 1, N'Bảo trì Bác', 10)

--select sum(sotien) as 'Tong so tien'
--from hoatdong h join diadanh d on (h.ma_dd = d.ma_dd)
--where d.matinh = 54 and h.nam = 2017

--select t.tentinh as 'Ten tinh', sum(sotien) as 'Ngan sach'
--from (hoatdong h join diadanh d on (h.ma_dd = d.ma_dd)) join tinh t on (t.matinh = d.matinh)
--where h.nam = 2018
--group by t.matinh, t.tentinh
