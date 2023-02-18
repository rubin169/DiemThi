-- ETL lấy danh sách thí sinh không bị điểm liệt
Create procedure storepro_ChenDuLieu
as
begin
	Insert into [dbo].[TTThiSinhDiemKhongLiet]
		Select * from [dbo].[ThongTinThiSinh] t
		Where t.Mon1 > 0 and t.Mon2 > 0 and t.Mon3 > 0
end

Exec storepro_ChenDuLieu

Select * from [dbo].[TTThiSinhDiemKhongLiet]

-- Function in ra kết quả thi tuyển của thí sinh

Create function fn_LayThongTinThiSinh (@SoBaoDanh int)
returns @LayThongTinThiSinh table 
(
	SBD int,
	HoTen nvarchar(max),
	NguyenVong varchar(10),
	MaTruongTT varchar(20),
	TenTruong nvarchar(255)
)
as
begin
	insert into @LayThongTinThiSinh (SBD, HoTen, NguyenVong, MaTruongTT)
	Select @SoBaoDanh as SBD, HoTen = Ho + ' ' + Ten, NVTrungTuyen as NguyenVong,
	MaTruongTT = 
	Case
		 When NVTrungTuyen = 0 then N'Không trúng tuyển'
		 when NVTrungTuyen = 1 then NV1
	     when NvTrungTuyen = 2 then NV2
		 when NVTrungTuyen = 3 then NV3
	Else N'Trúng tuyển ngoài 3 nguyện vọng'
	end 
	From [dbo].[TTThiSinhDiemKhongLiet]
	Where @SoBaoDanh = SBD
	
	Update @LayThongTinThiSinh
	Set TenTruong = t.TenTruong
	From [dbo].[ThongTinTruong] t
	Where MaTruongTT = t.MaTruong
Return
end

select * from [dbo].[fn_LayThongTinThiSinh] (100002)

-- Con trỏ lấy ra số thí sinh có điểm cao nhất

DECLARE @SBD int
DECLARE @SBDm int
DECLARE	@Ho nvarchar(MAX)
DECLARE @Hom nvarchar(MAX)
DECLARE @Ten nvarchar(MAX)
DECLARE @Tenm nvarchar(MAX)
DECLARE @TenTruong nvarchar(MAX)
DECLARE @TenTruongm nvarchar(MAX)
DECLARE @TongDiem float
	set @TongDiem = 0
DECLARE @SSTongDiem float
	set @SSTongDiem = 0
DECLARE cursorDSThiSinhDuDKM cursor for
Select [SBD], [Ho], [Ten], [TenTruong], [TongDiem3Mon]
From [dbo].[TTThiSinhDiemKhongLiet]
Open cursorDSThiSinhDuDKM
FETCH NEXT FROM cursorDSThiSinhDuDKM into @SBD, @Ho, @Ten, @TenTruong, @TongDiem
While @@FETCH_STATUS = 0
begin
 if @SSTongDiem < @TongDiem
	begin
	set @SBDm = @SBD
	set @Hom = @Ho
	set @Tenm = @Ten
	set @TenTruongm = @TenTruong
	set @SSTongDiem = @TongDiem
	end
FETCH NEXT FROM cursorDSThiSinhDuDKM into @SBD, @Ho, @Ten, @TenTruong, @TongDiem
End
print N'Thí sinh có điểm cao nhất là: ' +convert(nvarchar(max),@SBDm) +'-' 
+@Hom +' ' +@Tenm +'-' +@TenTruongm +'-' +convert(nvarchar(max), @SSTongDiem)
Close cursorDSThiSinhDuDKM
DEALLOCATE cursorDSThiSinhDuDKM

-- Con trỏ lấy ra số thí sinh có điểm thấp nhất

DECLARE @SBD1 int
DECLARE @SBDmin int
DECLARE	@Ho1 nvarchar(MAX)
DECLARE @Homin nvarchar(MAX)
DECLARE @Ten1 nvarchar(MAX)
DECLARE @Tenmin nvarchar(MAX)
DECLARE @TenTruong1 nvarchar(MAX)
DECLARE @TenTruongmin nvarchar(MAX)
DECLARE @TongDiem1 float
	set @TongDiem1 = 0
DECLARE @SSTongDiem1 float
	set @SSTongDiem1 = 30
DECLARE cursorDSThiSinhDuDKMin cursor for
Select [SBD], [Ho], [Ten], [TenTruong], [TongDiem3Mon]
From  [dbo].[TTThiSinhDiemKhongLiet]
Open cursorDSThiSinhDuDKMin
FETCH NEXT FROM cursorDSThiSinhDuDKMin into @SBD1, @Ho1, @Ten1, @TenTruong1, @TongDiem1
While @@FETCH_STATUS = 0
begin
 if @SSTongDiem1 > @TongDiem1
	begin
	set @SBDmin = @SBD1
	set @Homin = @Ho1
	set @Tenmin = @Ten1
	set @TenTruongmin = @TenTruong1
	set @SSTongDiem1 = @TongDiem1
	end
FETCH NEXT FROM cursorDSThiSinhDuDKMin into @SBD1, @Ho1, @Ten1, @TenTruong1, @TongDiem1
End
print N'Thí sinh có điểm thấp nhất là: ' +convert(nvarchar(max),@SBDmin) +'-' 
+@Homin +' ' +@Tenmin +'-' +@TenTruongmin +'-' +convert(nvarchar(max), @SSTongDiem1)
Close cursorDSThiSinhDuDKMin
DEALLOCATE cursorDSThiSinhDuDKMin

-- Thống kê

Select a.SBD, b.TenQuan, a.NVTrungTuyen, a.TongDiem3Mon,
Case
When a.NVTrungTuyen = '0' then N'Không trúng tuyển'
when a.NVTrungTuyen = '1' then a.NV1
when a.NVTrungTuyen = '2' then a.NV2
when a.NVTrungTuyen = '3' then a.NV3
Else N'Trúng tuyển ngoài 3 nguyện vọng'
end as MaTruongTT
into Tam_TK
From [dbo].[TTThiSinhDiemKhongLiet] a 
left join [dbo].[ThongTinQuan] b on a.Quan = b.MaSo

Alter table Tam_TK
add TenTruongTT1 nvarchar(255);
update Tam_TK
Set TenTruongTT1 = c.TenTruong
From [dbo].[ThongTinTruong] c
Where MaTruongTT = c.MaTruong

Select * from [dbo].[Tam_TK]
Select [TenTruongTT1], count(*) as SLTT, ROUND(AVG([TongDiem3Mon]),2) as DiemTB_TrungTuyen, MAX([TongDiem3Mon]) as DiemCaoNhat,
MIN([TongDiem3Mon]) as DiemThapNhat
From [dbo].[Tam_TK] q
Group by [TenTruongTT1]
Order by [TenTruongTT1]

/*
Số lượng thí sinh trúng tuyển mỗi trường: (như bảng trên)
Có tổng số 72,845 thí sinh tham gia thi(không có điểm liệt), thí sinh đậu 3 NV đầu là 59,984, chiếm tỉ lệ 82,34% 
Trường có nhiều thí sinh đậu nhất là THPT 16 với 1024 thí sinh trúng tuyển
Trường có ít thí sinh đậu nhất là trường THPT 106 với 46 thí sinh trúng tuyển 
Trường có thí sinh điểm cao nhất đậu vào là THPT 63, số điểm là 28,25
Trường có thí sinh điểm thấp nhất đậu vào là THPT 106, số điểm là 3,75
Trường có điểm TB trúng tuyển cao nhất là THPT 63, điểm TB là 23,99
Trường có điểm TB trúng tuyển thấp nhất là THPT 106, điểm TB là 8,52
*/

Select [TenQuan], count(*) as SLTT, ROUND(AVG([TongDiem3Mon]),2) as DiemTB_TrungTuyen, MAX([TongDiem3Mon]) as DiemCaoNhat,
MIN([TongDiem3Mon]) as DiemThapNhat
From [dbo].[Tam_TK]
Where MaTruongTT not like N'Không trúng tuyển'
Group by [TenQuan]
Order by [TenQuan]

/*
Toàn thành phố có tổng số 72,845 thí sinh tham gia thi(không có điểm liệt), thí sinh đậu 3 NV đầu là 59,984, chiếm tỉ lệ 82,34%.
Trong đó quận Gò Vấp có số lượng thí sinh trúng tuyển nhiều nhất (4220 thí sinh), 
huyện Cần Giờ có số thí sinh trúng tuyển thấp nhất (981 thí sinh),
Điểm tổng 3 môn cao nhất thuộc về quận Tân Phú (28,25) và thấp nhất là huyện củ chi (3,25)
Điểm trung bình là 17,37. Có 8 quận huyện có điểm trên TB
*/


