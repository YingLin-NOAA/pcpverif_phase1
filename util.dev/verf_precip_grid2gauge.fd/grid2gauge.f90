      program grid2gauge
      use wgrib2api
!
! Compare gauge amounts to that of the nearest grid point.  
! 2015/11/17: started from verfgen (g2g) code.
!   The part about finding the nearest grid point: only works for 
!   polarstereographic grid for now
!
! 2017/07/18: read in grib1 (unit 11) or grib2 (unit 12) data.
!
! Finding the nearest grid point works for the following projections:
!   1) polarstereographic (done)
!   2) Lambert-conformal 
!   3) Lat-lon
!
! Gauge data:
!   from 2016/02/04:
!   38.85   77.04   0.52 DCA       1200
!   lat     lon     amt (in)       ending hhmm of 24h period
!   Longitude in the daily gauge file: western logitude is positive!
!
! I/O units
!   Input:
!     fort.11: model/analysis file (grib1)
!     fort.12: model/analysis file (grib2)
!     fort.13: gauge data after QC
!   Output:
!     fort.51: gauge id/lat/lon/gauge amt/nearest grid point amt
!
! Parameters:
!   nxmax,nymax   : Maximum dimension of precip arrays.  
!
      parameter(nxmax=7000,nymax=3500)  ! dimension of ConUS MRMS
! The gridded precip:
      real, allocatable :: pmod(:,:), ptmp(:,:)
      logical*1 mbit(nxmax,nymax), mtmp(nxmax*nymax)
      integer nxymax, nx, ny, mpds(200),mgds(200),jpds(200),jgds(200)
      real alat0, alon0, alonv 
      integer indx, i, j
! gauge info:
      character staid*10
      real glat, glon, gamt, xg, yg
      integer ig, jg
!
      nxymax=nxmax*nymax
      jpds = -1
!
      
!
! Read in model precip file:
      call baopenr(11,'fort.11',ibret)
      call getgb(11,0,nxymax,0,jpds,jgds,km,k,mpds,mgds,mtmp,ptmp,imret)
      write(6,*) 'Openning gridded file, ibret=',ibret,' imret=', imret      
      if (ibret /=0 .or. imret /= 0) then
        write(6,*) 'ibret, imret=', ibret, imret
        write(6,*) 'Error reading analysis file.  STOP'
        stop 
      endif
         
! For grids of
!   1) Polarstereographic
!   2) Lambert conformal
!   3) Lat/lon
      nx = mgds(2)
      ny = mgds(3)
  
      if ( mgds(1) == 0 ) then
        write(6,*) 'Input grid is lat/lon.'
        alat0=float(mgds(4))/1000.
        alon0=float(mgds(5))/1000.
        dx=mgds(9)
        dy=mgds(10)
      elseif ( mgds(1) == 3 ) then
        alat0=float(mgds(4))/1000.
        alon0=float(mgds(5))/1000.
        alonv=float(mgds(7))/1000.
        dx=mgds(8)
        alatan1=float(mgds(12))/1000.
        write(6,*) 'Input grid is Lambert Conformal, alatan1=', alatan1
      elseif ( mgds(1) == 5 ) then
        write(6,*) 'Input grid is Polarstereographic.'
        alat0=float(mgds(4))/1000.
        alon0=float(mgds(5))/1000.
        alonv=float(mgds(7))/1000.
        dx=mgds(8)
      else
        write(6,*) 'Projection undefined for grid2gauge GDS(1)=',             &
     &    mgds(1), ' STOP'
        stop
      endif

!      write(6,*) 'nx, ny, dx=', nx, ny, dx
!      write(6,*) 'alat0, alon0, alonv=', alat0, alon0, alonv
!
! Copy ptmp and mtmp into pmod and mbit (the way they were read in by getgb,
! they were essentially 1-d arrays.  2-dimensionalize them.
      indx = 0
      do j = 1, ny
        do i = 1, nx
          indx = indx + 1
          pmod(i,j) = ptmp(indx)
          mbit(i,j) = mtmp(indx)
        enddo
      enddo
! Go through each gauge report:
 20   continue
      read(12,*, end=100) glat, glon, gamt, staid
! Convert gauge reading from inch to mm:
      gamt=gamt*25.4
! Find the (i,j) point nearest to glat, glon.  Note that glon read in is 
! positive.  

      if ( mgds(1) == 0 ) then    
!       lat/lon
        call latlontoij(glat,-glon,alat0,alon0,dx,dy,ig,jg)  ! my subroutine
      elseif ( mgds(1) == 3 ) then
!       Lambert Conformal:
        call w3fb11(glat,-glon,alat0,alon0,dx,alonv,alatan1,xg,yg)
        ig=nint(xg)
        jg=nint(yg)
      elseif ( mgds(1) == 5 ) then
!       Polarstereographic:
        call w3fb06(glat,-glon,alat0,alon0,dx,alonv,xg,yg)  
        ig=nint(xg)
        jg=nint(yg)
      endif
!
! Gauge location is outside of grid domain?
      if (ig < 1 .or. ig > nx .or. jg < 1 .or. jg > ny) goto 20
!      if (ig < 1 .or. ig > nx .or. jg < 1 .or. jg > ny) then 
!        write(52,991) staid(1:8), glat, -glon, ig, jg
! 991    format(a8,2(1x,f7.2),3x, 2i7)
!        goto 20
!      endif
! Gauge location is in data void area?
!      if (.not.mbit(ig,jg)) goto 20
      if (.not.mbit(ig,jg)) then
        write(52,992) staid(1:8), glat, -glon, ig, jg, mbit(ig,jg)
 992    format(a8,2(1x,f7.2),3x, 2i7,3x,l1)
        go to 20
      endif
!      write(51,40) staid(1:8), glat, -glon, gamt, pmod(ig,jg)
!      for debugging, write out the (i,j) point nearest to the gauge.
      write(51,993) staid(1:8), glat, -glon, gamt, pmod(ig,jg), ig, jg
 40   format(a8, 2(1x,f7.2),3x, 2(1x,f7.2))
 993  format(a8, 2(1x,f7.2),3x, 2(1x,f7.2),3x,2i6)
! Back to read the next gauge
      go to 20
 100  continue
! 
      stop
      end
!   
      subroutine latlontoij(xlat,xlon,alat0,alon0,dx,dy,ix,jy)
! Given a pair of (lat,lon) coordinates, find the (i,j) coordinates closest
! to it.  
! 
! Examples:
!   gauge: DCA lat/lon: (38.85,-77.04)  (in the gauge input, lon is actually
!                                        77.04, but it was converted to -77.04
!                                        when this subroutine is called)
!   cmcglb, lat   26.000000 to  48.560000 by 0.240000
!           lon  235.000000 to 293.800000 by 0.240000
!           ix=nint((-77.04-(235,360.-360.))/0.24)
!             =nint(47.96/0.24)
!             =200
!
! xlon is negative for western coordinates.
      real xlat, xlon, alat0, alon0, dx, dy
      integer ix, jy
!     
      if (alon0 .gt. 180.) alon0=alon0-360.
      ix=nint((xlon-alon0)/dx)
      jy=nint((xlat-alon0)/dy)
      return
      end
