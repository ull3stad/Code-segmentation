function  [DS,JC]=DS_JC_EndoEpi(out,Mmyo,MmyoEpi,MmyoEndo)

  [nr,nc,nsl]=size(Mmyo);  

  SegMyo=(out.EpiMFD-out.EndoMFD);
  DS.MyoFDtot = EvaluaImagenDice(Mmyo(:,:,1:nsl),SegMyo(:,:,1:nsl));
  JC.MyoFDtot = EvaluaImagenJaccard(Mmyo(:,:,1:nsl),SegMyo(:,:,1:nsl));
  for i=1:nsl
      DS.MyoFD(i)=EvaluaImagenDice(Mmyo(:,:,i),SegMyo(:,:,i));
      JC.MyoFD(i) = EvaluaImagenJaccard(Mmyo(:,:,i),SegMyo(:,:,i));
  end
  
  %DS.Epitot = EvaluaImagenDice(MmyoEpi(:,:,1:nsl),out.EpiM(:,:,1:nsl));
  %JC.Epitot = EvaluaImagenJaccard(MmyoEpi(:,:,1:nsl),out.EpiM(:,:,1:nsl));
  DS.EpiFDtot = EvaluaImagenDice(MmyoEpi(:,:,1:nsl),out.EpiMFD(:,:,1:nsl));
  JC.EpiFDtot = EvaluaImagenJaccard(MmyoEpi(:,:,1:nsl),out.EpiMFD(:,:,1:nsl));
  
  for i=1:nsl
      %DS.Epi(i)=EvaluaImagenDice(MmyoEpi(:,:,i),out.EpiM(:,:,i));
      %JC.Epi(i) = EvaluaImagenJaccard(MmyoEpi(:,:,i),out.EpiM(:,:,i));
      DS.EpiFD(i)=EvaluaImagenDice(MmyoEpi(:,:,i),out.EpiMFD(:,:,i));
      JC.EpiFD(i) = EvaluaImagenJaccard(MmyoEpi(:,:,i),out.EpiMFD(:,:,i));      
  end
  
  %DS.Endotot = EvaluaImagenDice(MmyoEndo(:,:,1:nsl),out.EndoM(:,:,1:nsl));
  %JC.Endotot = EvaluaImagenJaccard(MmyoEndo(:,:,1:nsl),out.EndoM(:,:,1:nsl));
  DS.EndoFDtot = EvaluaImagenDice(MmyoEndo(:,:,1:nsl),out.EndoMFD(:,:,1:nsl));
  JC.EndoFDtot = EvaluaImagenJaccard(MmyoEndo(:,:,1:nsl),out.EndoMFD(:,:,1:nsl));
  
  
  for i=1:nsl
      %DS.Endo(i)=EvaluaImagenDice(MmyoEndo(:,:,i),out.EndoM(:,:,i));
      %JC.Endo(i) = EvaluaImagenJaccard(MmyoEndo(:,:,i),out.EndoM(:,:,i));
      DS.EndoFD(i)=EvaluaImagenDice(MmyoEndo(:,:,i),out.EndoMFD(:,:,i));
      JC.EndoFD(i) = EvaluaImagenJaccard(MmyoEndo(:,:,i),out.EndoMFD(:,:,i));
      
  end
  
  