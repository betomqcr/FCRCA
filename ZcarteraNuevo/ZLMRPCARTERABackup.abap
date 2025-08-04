*&---------------------------------------------------------------------*
*& Nombre del Programa: ZLMRPCARTERA
*& Título: Reporte Consolidacion de Cartera
*& Autor: Franklin Madrigal
*& Fecha de Creación: 21.03.2022
*& Descripción: Extraccion de toda informacion de Cartera
*&---------------------------------------------------------------------*
REPORT  zlmrpcartera NO STANDARD PAGE HEADING.

TABLES: vdarl.

DEFINE mc_days.

  call function 'ZTRFU_DAYS_BETWEEN_TWO_DATES'
    exporting
      i_datum_von   = &1
      i_datum_bis   = &2
      i_kz_incl_bis = '0'
      i_kz_ult_bis  = 'X'
    importing
      e_tage        = &3.

END-OF-DEFINITION.


DEFINE mc_columna.

  g_columns = gt_table->get_columns( ).

  g_column ?= g_columns->get_column( &1 ).

  g_column->set_long_text( &2 ).
  g_column->set_medium_text( &3 ).
  g_column->set_short_text( &4 ).

  "g_column->IS_KEY( &3 ).

  g_column->set_technical( &5 ).

END-OF-DEFINITION.

DEFINE mc_crea_rango.

  clear: &1.

  &1-sign   = &2. "I, E
  &1-option = &3. "EQ, BT
  &1-low    = &4.
  &1-high   = &5.

  append &1.

END-OF-DEFINITION.

DEFINE mc_output.

  call function 'CONVERSION_EXIT_ALPHA_OUTPUT'
    exporting
      input  = &1
    importing
      output = &1.

END-OF-DEFINITION.

DEFINE mc_date.

  if &1 is not initial.

    lv_sydatum = &1.

    clear &1.

    call function 'HRGPBS_HESA_DATE_FORMAT'
      exporting
        p_date           = lv_sydatum
      importing
        datestring       = &1.

*    call function 'CONVERT_DATE_TO_EXTERNAL'
*      exporting
*        date_internal            = lv_sydatum
*      importing
*        date_external            = &1
*      exceptions
*        date_internal_is_invalid = 1
*        others                   = 2.

  else.

    clear &1.

  endif.

END-OF-DEFINITION.



TYPES: BEGIN OF ty_datos,
         bukrs          TYPE bukrs,         "Sociedad
         gsart          TYPE vvsart,        "Clase producto
         stitel         TYPE stitel,        "Clase préstamo
         zzdesemadel    TYPE char10,        "Fecha adelando desembolso - zzdesemadel
         zzdesemclreal  TYPE char10,        "Fecha desembolso completo - zzdesemclreal
         zzdesemcompl   TYPE char10,        "DESEMBOLSO COMPLETO - zzdesemcompl
         ranl           TYPE ranl,          "Número de contrato
         rdarnehm       TYPE bp_partnr_new, "Interl.comercial
         rdarnehm_name  TYPE char100,       "Nombre Interl.comercial
         fecha_reporte  TYPE char10,        "Fecha del Reporte - datum - char10
         id_number      TYPE bu_id_number,  "Identificación Interl.comercial
         sondst         TYPE vvsondst,      "Categoria
         diasmora       TYPE i,             "Cantidad de Dias de Mora
         monto_ori      TYPE wrbtr,         "Monto Original
         cuota_pen      TYPE i,             "CUOTAS PENDIENTES
         cuota_ssegu    TYPE wrbtr,         "MONTO CUOTA SIN SEGURO
         cxc_seg        TYPE wrbtr,         "CUENTAS COBRAR SEG
         saldo_credito  TYPE wrbtr,         "SALDO MONTO CREDITO BASE
         int_acumula    TYPE wrbtr,         "Intereses acumulados
         int_sacumula   TYPE wrbtr,         "Intereses en suspenso
         int_nodevenga  TYPE wrbtr,         "Intereses no devengados
         atraso_amort   TYPE wrbtr,         "Part.Abiertas Amortización
         atraso_int     TYPE wrbtr,         "Part.Abiertas Intereses
         fec_ulintpag   TYPE char10,        "Fecha Ultima IntPagados - datum
         fec_ulamopag   TYPE char10,        "Fecha ultima amort pagados - datum
         fec_prox_cuota TYPE char10,        "Fecha vencimiento prox cuota - datum
         estado         TYPE text15,        "Esado de la cartera
         zzsuspendido   TYPE flag,          "Suspendido
         svzweck        TYPE svzweck,       "ESTADO PRE-JUDICIAL
         fecha_precj    TYPE char10,        "FECHA PRE-JUDICIAL - datum
         fecha_cj       TYPE char10,        "Fecha cobro judicial - datum
         dias_cj        TYPE i,             "Dias Cobro judicial
         zzplazo        TYPE zplazo,        "Plazo
         pkond          TYPE pkond,         "Tasa de interés
         zplazo_rest    TYPE zplazo,        "Plazo restante
         zpor_mora      TYPE pkond,         "Tasa Interes Moratoria
         fecha_venci    TYPE char10,        "Fecha Vencimiento Prestamo delfz
         amortiza_pag   TYPE wrbtr,         "Amortización Pagado
         int_pag        TYPE wrbtr,         "Intereses Pagados
         imora_pag      TYPE wrbtr,         "Int.Moratorios Pagados
         direccion      TYPE c LENGTH 50,   "direccion
         rdarnehm_dir   TYPE char100,       "Direccion Interl.comercial
         direccion_not  TYPE char100,       "direccion notificar
         zona_trans     TYPE lzone,         "Zona de transporte
         zzorgrecau     TYPE zorgrecau,     "Organización Recaudadora
         zzorgrecau_txt TYPE c LENGTH 50,   "Desc.Org Recaudadora
         zzoficial      TYPE char50,        "Oficial Cobro
         zzcodentigar   TYPE zcodentigar,   "Cesion Garantia
         zdescripenti   TYPE zdescripenti,  "Descripcion Cesion Garantia
         zzcontragaran  TYPE c LENGTH 50,   "Contrato Garantia
         zzproyecto     TYPE zcodproyecto,  "Proyecto
         zdescriproye   TYPE zdescriproye,  "Descripcion Proyecto
         tel_1          TYPE c LENGTH 10,   "Telefono 1
         tel_2          TYPE c LENGTH 10,   "Telefono 2
         tel_3          TYPE c LENGTH 10,   "Telefono 3
         tel_4          TYPE c LENGTH 10,   "Telefono 4
         tel_5          TYPE c LENGTH 10,   "Telefono 5
         tel_6          TYPE c LENGTH 10,   "Telefono 6
         zzfeformbono   TYPE char10,        "Fecha Formalización - zfeformbono
         zzorgcolab     TYPE zorgcolab,     "Organización Colaboradora
         zzorgcolab_txt TYPE c LENGTH 50,   "Descripcion Organización Colaboradora
         diasucuota     TYPE i,             "Días Int.Ult Cuota Pag
         zcant_gar      TYPE i,             "Cantidad de Garantias Asociadas
         zzmtaslote     TYPE string,        ""Tasación Lote zmtotasterreno,
         zztasvivienda  TYPE ztasvivienda,  "Tasación Vivienda
         precongastos   TYPE zprecongastos, "Presupuesto con Gastos
         zzanalista     TYPE zanalista,     "Profesional Analista
         zzanalista_txt TYPE c LENGTH 50,   "Descrip Profesional Analista
         zfinca         TYPE c LENGTH 50,   "FINCA
         zgradohip      TYPE c LENGTH 20,   "GRADO DE HIPOTECA
         tipmitriesg    TYPE c LENGTH 20,   "Tipo Mitigador Riesgo
         tipgar         TYPE c LENGTH 30,   "Tipo Garantia
         "zzprograma     TYPE zcodprogra,   "Programa
         "zdescriprog    TYPE zdescriprog,  "Descripcion Programa
         "zzproposito    TYPE zcodpropo,    "Proposito
         "zdescriprop    TYPE zdescriprop,  "Descripcion Proposito
         zzprograma     TYPE zdescriprog,   "Programa
         zzproposito    TYPE zdescriprop,   "Proposito
         zzfeboleta     TYPE char10,        "Fecha Boleta Amarilla - zfechboleta
         zzfiscal       TYPE zfiscal,       "Profesional Fiscal
         zzfiscal_txt   TYPE char50,        "Descripcion Profesional Fiscal
         sdtyp          TYPE vvsdtyp,       "Motivo Cancelación
         xlbez          TYPE xlbez,         "Des.Motivo Cancelación
         zzbonomax      TYPE zbonomax,      "Monto Bono Familiar
         zzcredmax      TYPE zcredmax,      "Monto Crédito Maximo
         zzingrebru     TYPE zingrebru,     "Monto Ingreso Bruto
         zzingrenet     TYPE zingrenet,     "Monto Ingreso Neto
         zzestrato(16)  TYPE p DECIMALS 2,  "Monto Estrato - zestrato
         zzpresupues    TYPE zpresupues,    "Monto Presupuesto
         zztasavivi     TYPE ztasavivi,     "Monto Tasación Vivienda
         zzmcompvent    TYPE zmcompvent,    "Monto Compra Venta
         zzcuotaing     TYPE zcuotaing,     "Monto Relacion Cuota Ingreso
         zzintsocial    TYPE zintsocial,    "Indicador Interes Social
         zzpatrimon     TYPE zpatrimon,     "Indicador Patrimonio
         zzsegrega      TYPE zsegrega,      "Indicador Segregación
         zzcodentirec   TYPE zcodentirec,   "Codigo Entidad Fuente Recursos
         zzcontrarecur  TYPE zcontrarecur,  "Número Contrato Fuente Recursos
         zztrasocial    TYPE ztrasocial,    "Int.Cial Trabajador Social
         zzprorespon    TYPE zprorespon,    "Int.Cial Profesional Responsable
         zznotario      TYPE znotario,      "Int.Profesional Notario
         zznpconstruc   TYPE znpconstruc,   "Número Permiso Constructivo
         zzfenpconstruc TYPE char10,        "Fecha Permiso Constructivo - zfenpconstruc
         zzriliquid     TYPE char10,        "Fecha Recibo Inf.Liquidación - zreifliquid
         zznumbono      TYPE znumbono,      "Número Bono
         zzfeembono     TYPE char10,        "Fecha Emisión Bono - zfeembono
         zzfecobono     TYPE char10,        "Fecha Cobro Bono - zfecobono
         zzfepabono     TYPE char10,        "Fecha Pago Bono - zfepabono
         zzfeanbono     TYPE char10,        "Fecha Anulación Bono - zfeanbono
         zzfeaprobanhvi TYPE char10,        "Fecha Aprobación Banhvi zfeaprobanhvi
         zzofibono      TYPE zofibono,      "Número Oficio Bono
         zznuacta       TYPE znuacta,       "Número Acta
         zzn_re_aporte  TYPE zn_re_aporte,  "Num.Deposito Recibo Aporte
         zzn_re_ahorro  TYPE zn_re_ahorro,  "Num.Deposito Recibo Ahorro
         zzn_re_estsocial TYPE zn_re_estsocial,  "Num.Recibo Estudio Social
         zzn_re_avaluo  TYPE zn_re_avaluo,       "Num.Deposito Recibo Avaluo
         zzpresingastos TYPE zpresingastos,      "Mto.Presup Construcción sin Gastos
         zzprecongastos   TYPE zprecongastos,    "Mto.Presup Construcción con Gastos
         zzmontavaluo     TYPE zmontavaluo,      "MtoAvaluo Pagar Cliente
         zztaslote        TYPE ztaslote,         "Monto Tasado Lote
         zzmontoaporte    TYPE zzmontoaporte,    "Monto Aporte
         zzmont_estsocial TYPE zzmont_estsocial, "Monto Estudio Social
         zzrestdeduc      TYPE zrestdeducciones, "Deducciones Restantes Desembolso
         zzhon_prof_re    TYPE zhon_prof_re,     "Honorarios Profesional Responsable
         zzfe_asig_fiscal TYPE char10,           "Fecha Asignación Fiscal - zfe_asig_fiscal
         zzmontoahorro    TYPE zmontoahorro,     "Monto Ahorro
         sstati           TYPE sstati,           "Status
         ranlalt1         TYPE ranlalt1,         "Num alternativo 1
*        santwhr          TYPE swhr,             "Moneda
       END   OF ty_datos,

*--------------------------------------------------------------------*
*BEGIN OF ty_datos_out,
*         bukrs            TYPE string,  "Sociedad
*         gsart            TYPE string,  "Clase producto
*         stitel           TYPE string,  "Clase préstamo
*         zzdesemadel      TYPE string,  "Fecha adelando desembolso - zzdesemadel
*         zzdesemclreal    TYPE string,  "Fecha desembolso completo - zzdesemclreal
*         zzdesemcompl     TYPE string,  "DESEMBOLSO COMPLETO
*         ranl             TYPE string,  "Número de contrato
*         rdarnehm         TYPE string,  "Interl.comercial
*         rdarnehm_name    TYPE string,  "Nombre Interl.comercial
*         fecha_reporte    TYPE string,  "Fecha del Reporte - datum
*         id_number        TYPE string,  "Identificación Interl.comercial
*         sondst           TYPE string,  "Categoria
*         diasmora         TYPE string,  "Cantidad de Dias de Mora
*         monto_ori        TYPE string,  "Monto Original
*         cuota_pen        TYPE string,  "CUOTAS PENDIENTES
*         cuota_ssegu      TYPE string,  "MONTO CUOTA SIN SEGURO
*         cxc_seg          TYPE string,  "CUENTAS COBRAR SEG
*         saldo_credito    TYPE string,  "SALDO MONTO CREDITO BASE
*         int_acumula      TYPE string,  "Intereses acumulados
*         int_sacumula     TYPE string,  "Intereses en suspenso
*         int_nodevenga    TYPE string,  "Intereses no devengados
*         atraso_amort     TYPE string,  "Part.Abiertas Amortización
*         atraso_int       TYPE string,  "Part.Abiertas Intereses
*         fec_ulintpag     TYPE string,  "Fecha Ultima IntPagados - datum
*         fec_ulamopag     TYPE string,  "Fecha ultima amort pagados - datum
*         fec_prox_cuota   TYPE string,  "Fecha vencimiento prox cuota - datum
*         estado           TYPE string,  "Esado de la cartera
*         zzsuspendido     TYPE string,  "Suspendido
*         svzweck          TYPE string,  "ESTADO PRE-JUDICIAL
*         fecha_precj      TYPE string,  "FECHA PRE-JUDICIAL - datum
*         fecha_cj         TYPE string,  "Fecha cobro judicial - datum
*         dias_cj          TYPE string,  "Dias Cobro judicial
*         zzplazo          TYPE string,  "Plazo
*         pkond            TYPE string,  "Tasa de interés
*         zplazo_rest      TYPE string,  "Plazo restante
*         zpor_mora        TYPE string,  "Tasa Interes Moratoria
*         fecha_venci      TYPE string,  "Fecha Vencimiento Prestamo
*         amortiza_pag     TYPE string,  "Amortización Pagado
*         int_pag          TYPE string,  "Intereses Pagados
*         imora_pag        TYPE string,  "Int.Moratorios Pagados
*         direccion        TYPE string,  "direccion
*         rdarnehm_dir     TYPE string,  "Direccion Interl.comercial
*         direccion_not    TYPE string,  "direccion notificar
*         zona_trans       TYPE string,  "Zona de transporte
*         zzorgrecau       TYPE string,  "Organización Recaudadora
*         zzorgrecau_txt   TYPE string,  "Desc.Org Recaudadora
*         zzoficial        TYPE string,  "Oficial Cobro
*         zzcodentigar     TYPE string,  "Cesion Garantia
*         zdescripenti     TYPE string,  "Descripcion Cesion Garantia
*         zzcontragaran    TYPE string,  "Contrato Garantia
*         zzproyecto       TYPE string,  "Proyecto
*         zdescriproye     TYPE string,  "Descripcion Proyecto
*         tel_1            TYPE string,  "Telefono 1
*         tel_2            TYPE string,  "Telefono 2
*         tel_3            TYPE string,  "Telefono 3
*         tel_4            TYPE string,  "Telefono 4
*         tel_5            TYPE string,  "Telefono 5
*         tel_6            TYPE string,  "Telefono 6
*         zzfeformbono     TYPE string,  "Fecha Formalización - zfeformbono
*         zzorgcolab       TYPE string,  "Organización Colaboradora
*         zzorgcolab_txt   TYPE string,  "Descripcion Organización Colaboradora
*         diasucuota       TYPE string,  "Días Int.Ult Cuota Pag
*         zcant_gar        TYPE string,  "Cantidad de Garantias Asociadas
*         zzmtaslote       TYPE string,  "Tasación Lote
*         zztasvivienda    TYPE string,  "Tasación Vivienda
*         precongastos     TYPE string,  "Presupuesto con Gastos
*         zzanalista       TYPE string,  "Profesional Analista
*         zzanalista_txt   TYPE string,  "Descrip Profesional Analista
*         zfinca           TYPE string,  "FINCA
*         zgradohip        TYPE string,  "GRADO DE HIPOTECA
*         tipmitriesg      TYPE string,  "Tipo Mitigador Riesgo
*         tipgar           TYPE string,  "Tipo Garantia
*         "zzprograma      TYPE STRING,  "Programa
*         "zdescriprog     TYPE STRING,  "Descripcion Programa
*         "zzproposito     TYPE STRING,  "Proposito
*         "zdescriprop     TYPE STRING,  "Descripcion Proposito
*         zzprograma       TYPE string,  "Programa
*         zzproposito      TYPE string,  "Proposito
*         zzfeboleta       TYPE string,  "Fecha Boleta Amarilla - zfechboleta
*         zzfiscal         TYPE string,  "Profesional Fiscal
*         zzfiscal_txt     TYPE string,  "Descripcion Profesional Fiscal
*         sdtyp            TYPE string,  "Motivo Cancelación
*         xlbez            TYPE string,  "Des.Motivo Cancelación
*         zzbonomax        TYPE string,  "Monto Bono Familiar
*         zzcredmax        TYPE string,  "Monto Crédito Maximo
*         zzingrebru       TYPE string,  "Monto Ingreso Bruto
*         zzingrenet       TYPE string,  "Monto Ingreso Neto
*         zzestrato        TYPE string,  "Monto Estrato
*         zzpresupues      TYPE string,  "Monto Presupuesto
*         zztasavivi       TYPE string,  "Monto Tasación Vivienda
*         zzmcompvent      TYPE string,  "Monto Compra Venta
*         zzcuotaing       TYPE string,  "Monto Relacion Cuota Ingreso
*         zzintsocial      TYPE string,  "Indicador Interes Social
*         zzpatrimon       TYPE string,  "Indicador Patrimonio
*         zzsegrega        TYPE string,  "Indicador Segregación
*         zzcodentirec     TYPE string,  "Codigo Entidad Fuente Recursos
*         zzcontrarecur    TYPE string,  "Número Contrato Fuente Recursos
*         zztrasocial      TYPE string,  "Int.Cial Trabajador Social
*         zzprorespon      TYPE string,  "Int.Cial Profesional Responsable
*         zznotario        TYPE string,  "Int.Profesional Notario
*         zznpconstruc     TYPE string,  "Número Permiso Constructivo
*         zzfenpconstruc   TYPE string,  "Fecha Permiso Constructivo - zfenpconstruc
*         zzriliquid       TYPE string,  "Fecha Recibo Inf.Liquidación - zreifliquid
*         zznumbono        TYPE string,  "Número Bono
*         zzfeembono       TYPE string,  "Fecha Emisión Bono - zfeembono
*         zzfecobono       TYPE string,  "Fecha Cobro Bono - zfecobono
*         zzfepabono       TYPE string,  "Fecha Pago Bono - zfepabono
*         zzfeanbono       TYPE string,  "Fecha Anulación Bono - zfeanbono
*         zzfeaprobanhvi   TYPE string,  "Fecha Aprobación Banhvi
*         zzofibono        TYPE string,  "Número Oficio Bono
*         zznuacta         TYPE string,  "Número Acta
*         zzn_re_aporte    TYPE string,  "Num.Deposito Recibo Aporte
*         zzn_re_ahorro    TYPE string,  "Num.Deposito Recibo Ahorro
*         zzn_re_estsocial TYPE string,  "Num.Recibo Estudio Social
*         zzn_re_avaluo    TYPE string,  "Num.Deposito Recibo Avaluo
*         zzpresingastos   TYPE string,  "Mto.Presup Construcción sin Gastos
*         zzprecongastos   TYPE string,  "Mto.Presup Construcción con Gastos
*         zzmontavaluo     TYPE string,  "MtoAvaluo Pagar Cliente
*         zztaslote        TYPE string,  "Monto Tasado Lote
*         zzmontoaporte    TYPE string,  "Monto Aporte
*         zzmont_estsocial TYPE string,  "Monto Estudio Social
*         zzrestdeduc      TYPE string,  "Deducciones Restantes Desembolso
*         zzhon_prof_re    TYPE string,  "Honorarios Profesional Responsable
*         zzfe_asig_fiscal TYPE string,  "Fecha Asignación Fiscal - zfe_asig_fiscal
*         zzmontoahorro    TYPE string,  "Monto Ahorro
*         sstati           TYPE string,  "Status
*         ranlalt1         TYPE string,  "Num alternativo 1
*         santwhr          TYPE string,  "Moneda
*       END   OF ty_datos_out,
*--------------------------------------------------------------------*

       BEGIN OF ty_partida,
         bukrs TYPE	bukrs,
         kunnr TYPE	kunnr,
         vertn TYPE ranl,
         waers TYPE waers,
         wrbtr TYPE	wrbtr,
       END   OF ty_partida,


        BEGIN OF type_garantias,
         idvaloper     TYPE zcmfinangarant-idvaloper,
         codgrado      TYPE zcmfinangarant-codgrado,
         numerofinca   TYPE zcmgarantia-numerofinca,
         tipdocleg     TYPE zcmgarantia-tipdocleg,
         tipgar        TYPE zcmgarantia-tipgar,
         estado        TYPE zcmgarantia-estado,
         status        TYPE zcmgarantia-status,
         descrip       TYPE zcmtipgar-descrip,
         mtotasterreno TYPE zcmgarantreal-mtotasterreno,
  END OF type_garantias,

  BEGIN OF ty_totgarant,
          idvaloper TYPE zcmfinangarant-idvaloper,
          total     TYPE i,
    END OF ty_totgarant,

  BEGIN OF ty_pagos,
          ranl    TYPE ranl,
          sbewart TYPE sbewart,
          ddispo  TYPE ddispo,
          bbwhr   TYPE bbwhr,
  END   OF ty_pagos,

  BEGIN OF ty_kopo,
          rkey1    TYPE rkey1,
          skoart   TYPE skoart,
          dguel_kp TYPE dguel_kp,
          pkond    TYPE pkond,
          bkond    TYPE bkond,
  END   OF ty_kopo,

  BEGIN OF y_field,
         nombre TYPE c LENGTH 30 ,
    END OF y_field,

  BEGIN OF ty_proxcuota,
         ranl   TYPE ranl,
         ddispo TYPE ddispo,
    END OF ty_proxcuota,

  BEGIN OF ty_contrato,
         ranl TYPE ranl,
         briwr TYPE vvbriwr,
       END   OF ty_contrato.

DATA: gt_vdarl      TYPE STANDARD TABLE OF vdarl,
      *gt_vdarl     TYPE STANDARD TABLE OF vdarl,
      gt_but000     TYPE HASHED TABLE OF but000 WITH UNIQUE KEY partner,
      gt_adrc       TYPE HASHED TABLE OF adrc   WITH UNIQUE KEY addrnumber,
      gt_adr2       TYPE STANDARD TABLE OF adr2,
      gt_but0id     TYPE SORTED TABLE OF but0id WITH NON-UNIQUE KEY partner,
      gt_but050     TYPE SORTED TABLE OF but050 WITH NON-UNIQUE KEY partner1,
      gt_but021_fs  TYPE SORTED TABLE OF but021_fs WITH NON-UNIQUE KEY partner adr_kind,
      "*gt_but021_fs TYPE SORTED TABLE OF but021_fs WITH NON-UNIQUE KEY partner adr_kind,
      "gt_zenti     TYPE STANDARD TABLE OF zentidades,
      gt_zproye     TYPE HASHED TABLE OF zproyectos WITH UNIQUE KEY zcodproyecto,
      gt_zprogra    TYPE SORTED TABLE OF zprogramas WITH NON-UNIQUE KEY zgsart zcodprogra,
      gt_zproposito TYPE SORTED TABLE OF zproposito WITH NON-UNIQUE KEY zgsart zcodprogra zcodpropo,
      gt_zenti      TYPE HASHED TABLE OF zentidades WITH UNIQUE KEY zcodentidad,
      gt_td02t      TYPE HASHED TABLE OF td02t WITH UNIQUE KEY sdtyp,

      gt_proxcuota TYPE STANDARD TABLE OF ty_proxcuota,
      gw_proxcuota TYPE ty_proxcuota,

      gt_promes    TYPE STANDARD TABLE OF zpromesas,
      "gt_vzzkoko  TYPE HASHED TABLE OF vzzkoko WITH UNIQUE KEY rkey1,
      gt_vzzkoko   TYPE STANDARD TABLE OF vzzkoko,
      gt_vzzkopo   TYPE STANDARD TABLE OF vzzkopo,
      gt_csinseg   TYPE STANDARD TABLE OF vzzkopo,

      gt_kopo      TYPE STANDARD TABLE OF ty_kopo,
      gw_kopo      TYPE ty_kopo,
      gt_tkopo     TYPE STANDARD TABLE OF ty_kopo,

      gt_vdbepp    TYPE SORTED TABLE OF vdbepp WITH NON-UNIQUE KEY ranl ddispo,
      gt_vdbepp_x  TYPE SORTED TABLE OF vdbepp WITH NON-UNIQUE KEY ranl ddispo,   "TYPE STANDARD TABLE OF vdbepp,
      gv_lines_vdbepp_x TYPE i,

      gt_td10t     TYPE HASHED TABLE OF td10t WITH UNIQUE KEY ssonder,

      gt_vis_vdbevi TYPE STANDARD TABLE OF vissr_vdbevi,

      gt_bsid      TYPE STANDARD TABLE OF bsid,

      gt_bsid_prox TYPE STANDARD TABLE OF bsid,

      gt_bsid_pend TYPE STANDARD TABLE OF bsid,
      gt_nodevenga TYPE STANDARD TABLE OF ty_partida,
      gt_pendiente TYPE STANDARD TABLE OF ty_partida,

      gt_xcobrar TYPE STANDARD TABLE OF ty_partida,

      gt_bsid_mora TYPE STANDARD TABLE OF bsid,
      gt_bsid_amor TYPE STANDARD TABLE OF ty_partida,
      gt_bsid_int  TYPE STANDARD TABLE OF ty_partida,
      gt_sus_acum  TYPE STANDARD TABLE OF ty_partida,
      gw_partida   TYPE ty_partida,

      gt_pagos  TYPE STANDARD TABLE OF ty_pagos,
      *gt_pagos TYPE STANDARD TABLE OF ty_pagos,
      gt_tpagos TYPE STANDARD TABLE OF ty_pagos,
      "*gt_tpagos TYPE STANDARD TABLE OF ty_pagos,
      gw_pagos TYPE ty_pagos,

      gt_datos TYPE STANDARD TABLE OF ty_datos,
      gw_datos TYPE ty_datos,

      gt_vdbevi    TYPE STANDARD TABLE OF vissr_vdbevi, "ty_datos,
      gt_vdbevi_01 TYPE STANDARD TABLE OF vissr_vdbevi,

      lv_zzmtaslote TYPE string,

*      gt_out   TYPE STANDARD TABLE OF ty_datos_out,
*      gw_out   TYPE ty_datos_out,

      gt_garantias TYPE SORTED TABLE OF type_garantias WITH NON-UNIQUE KEY idvaloper,

      gt_tipgrado TYPE HASHED TABLE OF zcmtipgrado WITH UNIQUE KEY codgrado,

      gt_totgarant TYPE HASHED TABLE OF ty_totgarant WITH UNIQUE KEY idvaloper,

      gt_contratos TYPE HASHED TABLE OF zcontratos WITH UNIQUE KEY codigo,

      gv_days  TYPE i,

      gv_tabix TYPE sy-tabix,

      gv_provincia TYPE string,

      gt_tzont TYPE STANDARD TABLE OF tzont,

      ra_amort TYPE RANGE OF sbewart WITH HEADER LINE,
      ra_inter TYPE RANGE OF sbewart WITH HEADER LINE,

      gt_field   TYPE STANDARD TABLE OF y_field,
      gw_field   TYPE y_field,

      ts_texto TYPE STANDARD TABLE OF string,
      wa_texto TYPE string,

      lv_sydatum TYPE sy-datum,

      gt_zcartera TYPE STANDARD TABLE OF zlmtcartera,
      gw_zcartera TYPE zlmtcartera,

      lv_skokoart TYPE skokoart,
      gv_flag_tel TYPE c,

      gv_months   TYPE i,

*--------------------------------------------------------------------*
      lv_lines     TYPE i,
      lv_msg(80)   TYPE c,
      lv_taskname  TYPE numc10 VALUE '0',
      lv_excp_flag TYPE flag,

      gv_snd_task   TYPE i,
      gv_ptask      TYPE i,
      gv_rcv_task   TYPE i,
      w_rloam	      TYPE rloam,
      lv_contador   TYPE i,
      gt_contrato   TYPE STANDARD TABLE OF ty_contrato,
      gw_contrato   LIKE LINE OF gt_contrato.
*--------------------------------------------------------------------*

*------------------------------------------------*
* VARIABLES ALV
*------------------------------------------------*
DATA: g_layout    TYPE REF TO cl_salv_layout,
      g_key       TYPE salv_s_layout_key,
      gt_table    TYPE REF TO cl_salv_table,
      g_sort      TYPE REF TO cl_salv_sorts,
      g_functions TYPE REF TO cl_salv_functions,
      g_dsp       TYPE REF TO cl_salv_display_settings,
      g_columns   TYPE REF TO cl_salv_columns_table,
      g_column    TYPE REF TO cl_salv_column_table,
      g_color     TYPE lvc_s_colo,
      gt_events   TYPE REF TO cl_salv_events_table,
*     g_events     TYPE REF TO lcl_handle_events,
      g_agg       TYPE REF TO cl_salv_aggregations,
      g_sel       TYPE REF TO cl_salv_selections,

      gt_cols     TYPE salv_t_column_ref,
      gw_cols     LIKE LINE OF gt_cols,

      g_grid      TYPE REF TO cl_gui_alv_grid,
      gt_fieldcat TYPE lvc_t_fcat,
      gs_layout   TYPE lvc_s_layo,
      gs_variant  TYPE disvariant,

      g_header    TYPE REF TO cl_salv_form_layout_grid,
      g_h_label   TYPE REF TO cl_salv_form_label,
      g_h_flow    TYPE REF TO cl_salv_form_layout_flow.

FIELD-SYMBOLS: <fs_vdarl>   TYPE vdarl,
               <fs_but000>  TYPE but000,
               <fs_but0id>  TYPE but0id,
               <fs_but021>  TYPE but021_fs,
               <fs_adrc>    TYPE adrc,
               <fs_adr2>    TYPE adr2,
               <fs_but050>  TYPE but050,
               <fs_vzzkoko> TYPE vzzkoko,
               <fs_zproye>  TYPE zproyectos,
               <fs_zprogra> TYPE zprogramas,
               <fs_zpropos> TYPE zproposito,
               <fs_zenti>   TYPE zentidades,
               <fs_td02t>   TYPE td02t,
               <fs_promes>  TYPE zpromesas,
               <fs_bsid>    TYPE bsid,
               <fs_bsid_mora> TYPE bsid,
               <fs_int>       TYPE ty_partida,
               <fs_amor>      TYPE ty_partida,
               <fs_vdbepp>    TYPE vdbepp,
               <fs_td10t>     TYPE td10t,
               <fs_garantias> TYPE type_garantias,
               <fs_tipgrado>  TYPE zcmtipgrado,
               <fs_totgarant> TYPE ty_totgarant,
               <fs_contratos> TYPE zcontratos,
               <fs_pendiente> TYPE ty_partida,
               <fs_xcobrar>   TYPE ty_partida,
               <fs_vzzkopo>   TYPE vzzkopo,
               <fs_pagos>     TYPE ty_pagos,
               <fs_pagos*>    TYPE ty_pagos,
               <fs_tzont>     TYPE tzont,
               <fs_kopo>      TYPE ty_kopo,
               <fs_proxcuota> TYPE ty_proxcuota,
               <fs_contrato>  TYPE ty_contrato,
               <fs_datos>     TYPE ty_datos,
               <fs_vdbevi>    TYPE vissr_vdbevi.

******************************************************************
* PARAMETERS *
******************************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-t00.

PARAMETERS: pa_bukrs TYPE bsad-bukrs DEFAULT 'FCC1',
            pa_fecha TYPE sy-datum   DEFAULT sy-datum.

SELECT-OPTIONS: so_rdar   FOR vdarl-rdarnehm, "Interlocutor Comercial
                so_ranl   FOR vdarl-ranl,     "N° Contrato
*               so_santw  FOR vdarl-santwhr,  "Moneda
                so_gsart  FOR vdarl-gsart,    "Cl.Producto
                so_sonds  FOR vdarl-sondst,   "Categoria
                so_ssond  FOR vdarl-ssonder,  "Estado Cartera
                so_stati  FOR vdarl-sstati DEFAULT '60', "Status Contrato
                so_dist   FOR vdarl-lc_disbursement DEFAULT '2' TO '3'."Estado Pago

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-t01.

PARAMETERS:  pa_t1   AS CHECKBOX DEFAULT space,
             pa_file AS CHECKBOX DEFAULT '',
             pa_alv  AS CHECKBOX DEFAULT 'X',
             pa_tab  AS CHECKBOX DEFAULT ''.
"pa_job  AS CHECKBOX DEFAULT '' .

PARAMETERS: pa_path LIKE rlgrap-filename DEFAULT 'C:\'.

SELECTION-SCREEN END OF BLOCK b2.


*
*PARAMETERS: pa_r1 RADIOBUTTON GROUP rad1 DEFAULT 'X',
*            pa_r2 RADIOBUTTON GROUP rad1,
*            pa_r3 RADIOBUTTON GROUP rad1.

SELECTION-SCREEN END OF BLOCK b1.


INITIALIZATION.
  mc_crea_rango ra_amort 'I' 'EQ' '0115' space.
  mc_crea_rango ra_amort 'I' 'EQ' '0120' space.
  mc_crea_rango ra_amort 'I' 'EQ' '0125' space.

  mc_crea_rango ra_inter 'I' 'EQ' '0110' space.
  mc_crea_rango ra_inter 'I' 'EQ' 'Z110' space.

START-OF-SELECTION.

  REFRESH: gt_vdarl[],
          *gt_vdarl[],
           gt_but000[],
           gt_but0id[].

  IF pa_t1 = 'X'. "Ejecutar reporte con fecha T-1 (Dia Anterior)
    pa_fecha = pa_fecha - 1.
  ENDIF.

*--------------------------------------------------------------------*
* VDARL
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_vdarl
    FROM vdarl
   WHERE bukrs = pa_bukrs
     AND ranl     IN so_ranl
     AND sstati   IN so_stati
     AND gsart    IN so_gsart
*    AND santwhr  IN so_santw
     AND ssonder  IN so_ssond
     AND sondst   IN so_sonds
     AND rdarnehm IN so_rdar
     AND lc_disbursement IN so_dist.

  IF gt_vdarl IS INITIAL.

    MESSAGE 'No Hay Contratos Validos, Verifique la Seleccion' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.

  ENDIF.

  PERFORM f_saldo_credito. "Saldo Monto Credito base

  SORT gt_contrato BY ranl.

*--------------------------------------------------------------------*
* TD10T
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_td10t
    FROM td10t
   WHERE spras = 'S'.

*--------------------------------------------------------------------*
* BUT000
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_but000
    FROM but000
   WHERE partner IS NOT NULL.

  "     FOR ALL ENTRIES IN *gt_vdarl
  "   WHERE partner = *gt_vdarl-rdarnehm.

*--------------------------------------------------------------------*
* BUT0ID
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_but0id
    FROM but0id
     FOR ALL ENTRIES IN gt_vdarl "gt_but000
   WHERE partner = gt_vdarl-rdarnehm.  "gt_but000-partner.

*--------------------------------------------------------------------*
* BUT050
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_but050
    FROM but050
     FOR ALL ENTRIES IN gt_vdarl "gt_but000
   WHERE partner1 = gt_vdarl-rdarnehm  "gt_but000-partner
     AND reltyp   = 'ZBUR05'.

*--------------------------------------------------------------------*
* BUT021_FS
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_but021_fs
    FROM but021_fs
     FOR ALL ENTRIES IN gt_vdarl "gt_but000
   WHERE partner = gt_vdarl-rdarnehm  "gt_but000-partner.
     AND adr_kind IN ('0001', 'XXDEFAULT').

  DELETE ADJACENT DUPLICATES FROM gt_but021_fs COMPARING partner addrnumber.

*--------------------------------------------------------------------*
* TZONT
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_tzont
    FROM tzont
   WHERE spras = 'S'
     AND land1 = 'CR'.

  SORT gt_tzont BY zone1.

*--------------------------------------------------------------------*
* ADRC
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_adrc
    FROM adrc
     FOR ALL ENTRIES IN gt_but021_fs
   WHERE addrnumber = gt_but021_fs-addrnumber.

*--------------------------------------------------------------------*
* ADR2
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_adr2
    FROM adr2
    FOR ALL ENTRIES IN gt_adrc
  WHERE addrnumber = gt_adrc-addrnumber
    AND valid_from <= sy-datum
    AND ( valid_to >= sy-datum OR valid_to = '' ).

  DELETE gt_adr2 WHERE flg_nouse = 'X'.

* SORT gt_adr2 BY addrnumber tel_number.
  SORT gt_adr2 BY addrnumber valid_from DESCENDING.

  DELETE ADJACENT DUPLICATES FROM gt_adr2 COMPARING addrnumber tel_number.

*--------------------------------------------------------------------*
* ZPROYECTOS
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_zproye
    FROM zproyectos
     FOR ALL ENTRIES IN gt_vdarl
   WHERE zcodproyecto = gt_vdarl-zzproyecto.

*--------------------------------------------------------------------*
* ZENTIDADES
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_zenti
    FROM zentidades
     FOR ALL ENTRIES IN gt_vdarl
   WHERE zcodentidad = gt_vdarl-zzcodentigar
     AND zcodentidad IS NOT NULL.

*--------------------------------------------------------------------*
* ZPROGRAMAS
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_zprogra
    FROM zprogramas
     FOR ALL ENTRIES IN gt_vdarl
   WHERE zgsart     = gt_vdarl-gsart
     AND zcodprogra = gt_vdarl-zzprograma.

*--------------------------------------------------------------------*
* Motivo Cancelación
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_td02t
    FROM td02t
     FOR ALL ENTRIES IN gt_vdarl
   WHERE spras = 'S'
     AND sdtyp = gt_vdarl-sdtyp.

*--------------------------------------------------------------------*
* zproposito
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_zproposito
    FROM zproposito
     FOR ALL ENTRIES IN gt_vdarl
   WHERE zgsart     = gt_vdarl-gsart
     AND zcodprogra = gt_vdarl-zzprograma
     AND zcodpropo  = gt_vdarl-zzproposito.


*--------------------------------------------------------------------*
* ZPROMESAS
*--------------------------------------------------------------------*
  SELECT bukrs
         kunnr
         vertn
         zstat
         fecha_reg
    INTO CORRESPONDING FIELDS OF TABLE gt_promes
    FROM zpromesas
     FOR ALL ENTRIES IN gt_vdarl
   WHERE bukrs = gt_vdarl-bukrs
     AND kunnr = gt_vdarl-rdarnehm
     AND vertn = gt_vdarl-ranl
     AND zstat IN ('0034','0041').

  SORT gt_promes BY kunnr vertn zstat fecha_reg DESCENDING.

  DELETE ADJACENT DUPLICATES FROM gt_promes COMPARING bukrs kunnr vertn zstat.

*--------------------------------------------------------------------*
* VZZKOKO
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_vzzkoko
    FROM vzzkoko
     FOR ALL ENTRIES IN gt_vdarl
   WHERE bukrs  = gt_vdarl-bukrs
     AND rkey1  = gt_vdarl-ranl.
*     AND skokoart = 1.

  SORT gt_vzzkoko BY rkey1 skokoart.

*--------------------------------------------------------------------*
* VZZKPO
*--------------------------------------------------------------------*
  SELECT rkey1 skoart dguel_kp pkond bkond
    INTO TABLE gt_kopo
    FROM vzzkopo AS a
   WHERE bukrs  = pa_bukrs
     AND rkey1 IN so_ranl
     AND nlfd_ang = space
     AND skoart IN ('0201', '0603', '0261', '0262')
     AND dguel_kp IN ( SELECT MAX( dguel_kp )
                         FROM vzzkopo
                        WHERE bukrs  = pa_bukrs
                          AND rkey1  = a~rkey1
                          AND skoart = a~skoart ).


*select DISTINCT a~rkey1 a~skoart a~dguel_kp a~pkond a~bkond
*    into table gt_kopo
*    from vzzkopo as A
*    where bukrs  = pa_bukrs
*      and rkey1 in so_ranl
*      and skoart in ('0201', '0603', '0261', '0262')
*      and dguel_kp  =
*(
*  select MAX( dguel_kp )
*        from vzzkopo
*        where bukrs = pa_bukrs
*          and rkey1 = a~rkey1
*          and skoart = a~skoart
*          and dguel_kp = a~dguel_kp
*).

*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE gt_kopo
*    FROM vzzkopo
*    WHERE bukrs  = pa_bukrs
*      AND rkey1 IN so_ranl
*      AND skoart IN ('0201', '0603', '0261', '0262')
*      AND dguel_kp = ( SELECT MAX( dguel_kp ) from vzzkopo ).
  "GROUP BY rkey1 skoart pkond.


*  SELECT rkey1 MAX( DISTINCT dguel_kp ) skoart pkond bkond
*    INTO TABLE gt_kopo
*    FROM vzzkopo
*   WHERE bukrs  = pa_bukrs
*     AND rkey1 IN so_ranl
*     AND skoart IN ('0201', '0603', '0261', '0262')
*     AND dguel_kp <= pa_fecha
*    GROUP BY rkey1 skoart pkond bkond.

  SELECT rkey1 skoart MAX( dguel_kp ) SUM( pkond ) SUM( bkond )
    APPENDING TABLE gt_kopo
    FROM vzzkopo
   WHERE bukrs  = pa_bukrs
     AND rkey1 IN so_ranl
     AND nlfd_ang = space
     AND skoart IN ('9172','9173','9002','9003','9004')
     AND dguel_kp <= pa_fecha
   GROUP BY rkey1 skoart.

  SORT gt_kopo BY rkey1 skoart.
*  SORT gt_kopo BY rkey1 skoart ASCENDING dguel_kp DESCENDING .

*  DELETE ADJACENT DUPLICATES FROM gt_kopo COMPARING rkey1 skoart.

  LOOP AT gt_kopo ASSIGNING <fs_kopo>.

    CLEAR: gw_kopo.

    gw_kopo = <fs_kopo>.

    CLEAR: gw_kopo-dguel_kp.

    CASE <fs_kopo>-skoart.
      WHEN '0261' OR '0262'.

        gw_kopo-skoart = '0261'. "MONTO CUOTA SIN SEGURO

      WHEN '9172' OR '9173'.

        gw_kopo-skoart = '9172'. "MONTO CUENTAS X COBRAR SEGURO

      WHEN OTHERS.

    ENDCASE.

    COLLECT gw_kopo INTO gt_tkopo.

  ENDLOOP.

  SORT gt_tkopo BY rkey1 skoart.

*  SELECT *
*    INTO TABLE GT_VZZKOPO
*    FROM VZZKOPO
*     FOR ALL ENTRIES IN GT_VDARL
*   WHERE BUKRS  = GT_VDARL-BUKRS
*     AND RKEY1  = GT_VDARL-RANL
*     AND SKOART IN ('0201', '0261', '0262','0603')
*     AND DGUEL_KP <= PA_FECHA.
*
*  SORT GT_VZZKOPO BY RKEY1 SKOART.
*
*  GT_CSINSEG[] = GT_VZZKOPO[].
*
*  DELETE GT_VZZKOPO WHERE SKOART BETWEEN '0261' AND '0262'.
*
*  DELETE GT_CSINSEG WHERE SKOART = '0201' OR SKOART = '0603'.
*
*  DELETE ADJACENT DUPLICATES FROM GT_VZZKOPO COMPARING BUKRS RKEY1 SKOART.
*
*  SORT GT_CSINSEG BY RKEY1 DGUEL_KP DESCENDING.
*
*  DELETE ADJACENT DUPLICATES FROM GT_VZZKOPO COMPARING RKEY1 SKOART.
*
*  SORT GT_CSINSEG BY RKEY1 SKOART.


*--------------------------------------------------------------------*
* vissr_vdbevi
*--------------------------------------------------------------------*
  SELECT ranl sbewart MAX( ddispo ) SUM( bbwhr )
    INTO TABLE gt_pagos
    FROM vissr_vdbevi
   WHERE ranl IN so_ranl
     AND sstorno NOT IN ('1','2')
     AND sbewart IN ('3210','3225','3220','3238','3215', '3260', '3235' ) ", '0138' , 'Z138')
   GROUP BY ranl sbewart.

  SORT gt_pagos BY ranl sbewart.
*--------------------------------------------------------------------*
  IF gt_pagos[] IS NOT INITIAL.

    REFRESH: gt_vdbevi[],
             gt_vdbevi_01[].

    SELECT bukrs ranl sbewart rzebel ddispo
      INTO CORRESPONDING FIELDS OF TABLE gt_vdbevi
      FROM vissr_vdbevi
     WHERE ranl IN so_ranl
       AND sstorno = space
       AND sbewart LIKE '32%'.

    DELETE gt_vdbevi WHERE ( sbewart = '3260' OR
                             sbewart = '3238' OR
                             sbewart = '3210' ).            "= '3260'.

    SORT: gt_vdbevi BY ranl ddispo DESCENDING rzebel DESCENDING.

    DELETE ADJACENT DUPLICATES FROM gt_vdbevi COMPARING ranl ddispo rzebel.

    SELECT bukrs rbelkpfd ranl ddispo
      INTO CORRESPONDING FIELDS OF TABLE gt_vdbevi_01
      FROM vissr_vdbevi
       FOR ALL ENTRIES IN gt_vdbevi
     WHERE bukrs    = gt_vdbevi-bukrs
       AND rbelkpfd = gt_vdbevi-rzebel
       AND ranl IN so_ranl.


    SORT: gt_vdbevi_01 BY ranl ddispo DESCENDING rzebel DESCENDING.

    DELETE ADJACENT DUPLICATES FROM gt_vdbevi_01 COMPARING ranl.

    SORT: gt_vdbevi_01 BY ranl.

  ENDIF.
*--------------------------------------------------------------------*

  gw_pagos-sbewart = 'AMOR'.

  MODIFY gt_pagos FROM gw_pagos TRANSPORTING sbewart WHERE ( ( sbewart = '3225' )
                                                        OR   ( sbewart = '3215' )
                                                        OR   ( sbewart = '3220' )
                                                        OR   ( sbewart = '3238' )
                                                        OR   ( sbewart = '3235' ) ).

  gw_pagos-sbewart = 'INTE'.

  MODIFY gt_pagos FROM gw_pagos TRANSPORTING sbewart WHERE sbewart = '3210'.

  gw_pagos-sbewart = 'PAGA'.

  MODIFY gt_pagos FROM gw_pagos TRANSPORTING sbewart WHERE sbewart = '3260'.

   *gt_pagos[] = gt_pagos[].

  SORT: *gt_pagos BY ranl sbewart ddispo DESCENDING,
         gt_pagos BY ranl sbewart ddispo DESCENDING.

  DELETE ADJACENT DUPLICATES FROM *gt_pagos COMPARING ranl sbewart.

  LOOP AT gt_pagos ASSIGNING <fs_pagos>.

    CLEAR: gw_pagos.

    gw_pagos = <fs_pagos>.

    READ TABLE *gt_pagos ASSIGNING <fs_pagos*> WITH KEY ranl = <fs_pagos>-ranl
                                                     sbewart = <fs_pagos>-sbewart BINARY SEARCH.
    IF ( sy-subrc = 0 AND <fs_pagos*> IS ASSIGNED ).

      gw_pagos-ddispo = <fs_pagos*>-ddispo.

    ENDIF.

    COLLECT gw_pagos INTO gt_tpagos[].

  ENDLOOP.

  SORT gt_tpagos BY ranl sbewart.


*    CASE <fs_pagos>-sbewart.
*      WHEN 'AMOR'. "'3225' OR '3215' OR '3220' OR '3228' OR 'Z138'. "OR '0138' OR 'Z138'. " mtos amortizacion
*        "gw_pagos-sbewart = 'AMOR'.
*
*        COLLECT gw_pagos INTO gt_tpagos[].
*
*      WHEN '3210'. " mtos interes
*
*        "gw_pagos-sbewart = 'INTE'.
*
*        COLLECT gw_pagos INTO gt_tpagos[].
*
*
*      WHEN '3260'. " int moratorios pagados
*
*        "gw_pagos-sbewart = 'PAGA'.
*
*        COLLECT gw_pagos INTO gt_tpagos[].

*    ENDCASE.

*  ENDLOOP.

*  SORT gt_tpagos BY ranl sbewart.


*  SELECT *
*    INTO TABLE gt_vis_vdbevi
*    FROM vissr_vdbevi
*     FOR ALL ENTRIES IN gt_vdarl
*   WHERE bukrs = gt_vdarl-bukrs
*     AND ranl  = gt_vdarl-ranl
*     AND sstorno NOT IN ('1','2')
*     AND sbewart IN ('0125','0120','3210','3215','3220','3225','3228','3260').




*--------------------------------------------------------------------*
* contrato de garantia
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_contratos
    FROM zcontratos
   WHERE codigo IS NOT NULL.


*--------------------------------------------------------------------*
* TOTAL GARANTIAS
*--------------------------------------------------------------------*
  SELECT DISTINCT idvaloper COUNT( * )
    INTO TABLE gt_totgarant
    FROM zcmfinangarant
   WHERE idvaloper IS NOT NULL
   GROUP BY idvaloper.

*--------------------------------------------------------------------*
* GT_GARANTIAS
*--------------------------------------------------------------------*
  SELECT a~idvaloper
         a~codgrado
         b~numerofinca
         b~tipdocleg
         b~tipgar
         b~estado
         b~status
         d~descrip
         c~mtotasterreno
     INTO TABLE gt_garantias
     FROM zcmfinangarant AS a LEFT JOIN zcmgarantia AS b
       ON a~consecutivo = b~consecutivo INNER JOIN zcmtipgar AS d
       ON b~tipgar EQ d~tipgar LEFT JOIN zcmgarantreal AS c
       ON a~consecutivo = c~consecutivo
      FOR ALL ENTRIES IN gt_vdarl
    WHERE idvaloper = gt_vdarl-ranl.

  DELETE gt_garantias WHERE estado <> '1' AND status <> '1'.



*--------------------------------------------------------------------*
* zcmtipgrado
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_tipgrado
    FROM zcmtipgrado
   WHERE codgrado IS NOT NULL.

**--------------------------------------------------------------------*
** vdbepp
**--------------------------------------------------------------------*
*  SELECT *
*    INTO TABLE gt_vdbepp
*    FROM vdbepp
*     FOR ALL ENTRIES IN gt_vdarl
*   WHERE bukrs = gt_vdarl-bukrs
*     AND ranl  = gt_vdarl-ranl.
*
*  "SORT gt_vdbepp BY ranl ddispo ASCENDING.
*
*  DELETE gt_vdbepp WHERE ddispo <= pa_fecha.
*
*  DELETE ADJACENT DUPLICATES FROM gt_vdbepp COMPARING ranl.
*
*  "and ddispo ge p_fecha
*  "and ddispo like '%01'.

*--------------------------------------------------------------------*
* BSID
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_bsid
    FROM bsid
    FOR ALL ENTRIES IN gt_vdarl
  WHERE bukrs = gt_vdarl-bukrs
    AND kunnr = gt_vdarl-rdarnehm
    AND budat <= pa_fecha
    AND vertn = gt_vdarl-ranl.
  "AND vbewa IN ('0110', 'Z110', '0115' , '0120', '0125').

  SORT: gt_bsid BY vertn vbewa.

  gt_bsid_prox[] = gt_bsid[].

  LOOP AT gt_bsid ASSIGNING <fs_bsid>.

    CLEAR: gw_partida.

    MOVE-CORRESPONDING <fs_bsid> TO gw_partida.

    CASE <fs_bsid>-vbewa.
      WHEN '0115' OR '0120' OR '0125' .

        COLLECT gw_partida INTO gt_bsid_amor[].

      WHEN '0110' OR 'Z110'.

        COLLECT gw_partida INTO gt_bsid_int[].
    ENDCASE.

  ENDLOOP.                                                  "1000005186

  gt_bsid_mora[] = gt_bsid[].

  SORT: gt_bsid_mora BY vertn shkzg.

  DELETE gt_bsid_mora WHERE shkzg = 'H'.

  SORT: gt_bsid_mora BY vertn zfbdt ASCENDING.

  DELETE ADJACENT DUPLICATES FROM gt_bsid_mora COMPARING vertn.


*--------------------------------------------------------------------*
* CUOTAS PENDIENTES
*--------------------------------------------------------------------*
  gt_bsid_pend[] = gt_bsid[].

  DELETE gt_bsid_pend WHERE zfbdt > pa_fecha.

  SORT gt_bsid_pend BY vertn zfbdt.

  DELETE ADJACENT DUPLICATES FROM gt_bsid_pend COMPARING vertn zfbdt+0(6).

  LOOP AT gt_bsid_pend ASSIGNING <fs_bsid>.

    CLEAR: gw_partida.

    gw_partida-vertn = <fs_bsid>-vertn.
    gw_partida-wrbtr = 1.

    COLLECT gw_partida INTO gt_pendiente[].

  ENDLOOP.

  SORT: gt_pendiente BY vertn.

*--------------------------------------------------------------------*
* INTERESES NO DEVENGADOS
*--------------------------------------------------------------------*
  LOOP AT gt_bsid ASSIGNING <fs_bsid> WHERE ( ( zfbdt >= pa_fecha ) AND ( ( vbewa = '0110' ) OR ( vbewa = 'Z110' ) ) ).

    CLEAR: gw_partida.

    gw_partida-bukrs = <fs_bsid>-bukrs.
    gw_partida-kunnr = <fs_bsid>-kunnr.
    gw_partida-vertn = <fs_bsid>-vertn.
    gw_partida-waers = <fs_bsid>-waers.
    gw_partida-wrbtr = <fs_bsid>-wrbtr.

    COLLECT gw_partida INTO gt_nodevenga[].

  ENDLOOP.

*--------------------------------------------------------------------*
* PLAZO RESTANTE
*--------------------------------------------------------------------*
*  PERFORM f_plazo_restante.

*--------------------------------------------------------------------*
* INT ACUMULADOS - INT SUSPENSO
*--------------------------------------------------------------------*
  PERFORM f_intereses USING gt_bsid[]
                   CHANGING gt_sus_acum[].

*--------------------------------------------------------------------*
* vdbepp
*--------------------------------------------------------------------*
  SELECT *
    INTO TABLE gt_vdbepp
    FROM vdbepp
     FOR ALL ENTRIES IN gt_vdarl
   WHERE bukrs = gt_vdarl-bukrs
     AND ranl  = gt_vdarl-ranl.

  DELETE gt_vdbepp WHERE ddispo <= pa_fecha.

*--------------------------------------------------------------------*
  gt_vdbepp_x[] = gt_vdbepp[].

  DELETE ADJACENT DUPLICATES FROM gt_vdbepp_x COMPARING ranl ddispo. "ddispo+0(6).

  LOOP AT gt_vdbepp_x ASSIGNING <fs_vdbepp>.

    CLEAR: gw_partida.

    gw_partida-vertn = <fs_vdbepp>-ranl.
    gw_partida-wrbtr = 1.

    COLLECT gw_partida INTO gt_xcobrar[].

  ENDLOOP.
*--------------------------------------------------------------------*

  DELETE ADJACENT DUPLICATES FROM gt_vdbepp COMPARING ranl.

  SORT gt_bsid_prox BY bukrs vertn zfbdt ASCENDING.

  DELETE ADJACENT DUPLICATES FROM gt_bsid_prox COMPARING bukrs vertn.

  LOOP AT gt_vdbepp ASSIGNING <fs_vdbepp>.

    CLEAR: gw_proxcuota.

    gw_proxcuota-ranl   = <fs_vdbepp>-ranl.
    gw_proxcuota-ddispo = <fs_vdbepp>-ddispo.

    APPEND gw_proxcuota TO gt_proxcuota[].

  ENDLOOP.

  LOOP AT gt_bsid_prox ASSIGNING <fs_bsid> .

    CLEAR: gw_proxcuota.

    gw_proxcuota-ranl   = <fs_bsid>-vertn.
    gw_proxcuota-ddispo = <fs_bsid>-zfbdt.

    APPEND gw_proxcuota TO gt_proxcuota[].

  ENDLOOP.

  SORT gt_proxcuota BY ranl ddispo.

  DELETE ADJACENT DUPLICATES FROM gt_proxcuota COMPARING ranl.

END-OF-SELECTION.


  SORT gt_vdarl BY ranl.

  LOOP AT gt_vdarl ASSIGNING <fs_vdarl>.

    CLEAR: gw_datos,
           gw_zcartera.

    MOVE-CORRESPONDING <fs_vdarl> TO gw_datos.

    gw_datos-fecha_reporte = sy-datum. "FECHA DEL REPORTE

    gw_datos-precongastos = gw_datos-zzprecongastos. "Presupuesto con Gastos

    "gw_datos-zplazo_rest = <fs_vdarl>-zzplazo. "PLAZO RESTANTE

    IF <fs_vdarl>-ranlalt1 IS NOT INITIAL.

      CLEAR: gw_datos-zzmontoaporte,
             gw_datos-zzmontoahorro,
             gw_datos-zzbonomax.
    ENDIF.

    CLEAR: lv_skokoart.

    CASE <fs_vdarl>-sstati.
      WHEN '01'.
        lv_skokoart = '5'.
      WHEN '20'.
        lv_skokoart = '6'.
      WHEN '60' OR '90'.
        lv_skokoart = '1'.
    ENDCASE.

    READ TABLE gt_vzzkoko ASSIGNING <fs_vzzkoko> WITH KEY rkey1 = <fs_vdarl>-ranl
                                                       skokoart = lv_skokoart.
    IF ( sy-subrc = 0 AND <fs_vzzkoko> IS ASSIGNED ) .

*--------------------------------------------------------------------*
*      PERFORM f_convert_data USING <fs_vzzkoko>
*                          CHANGING gw_datos-zplazo_rest. "PLAZO RESTANTE

      READ TABLE gt_vdbevi_01 ASSIGNING <fs_vdbevi> WITH KEY ranl = <fs_vdarl>-ranl BINARY SEARCH.
      IF ( sy-subrc = 0 AND <fs_vdbevi> IS ASSIGNED ) .

        CLEAR: gv_months.

        CALL FUNCTION 'HR_99S_INTERVAL_BETWEEN_DATES'
          EXPORTING
            begda    = <fs_vdbevi>-ddispo
            endda    = <fs_vzzkoko>-delfz
*           TAB_MODE = ' '
          IMPORTING
            d_months = gv_months.

        gw_datos-zplazo_rest = gv_months. "PLAZO RESTANTE

      ELSE.

        gw_datos-zplazo_rest = <fs_vdarl>-zzplazo.  "PLAZO RESTANTE

      ENDIF.
*--------------------------------------------------------------------*

      gw_datos-fecha_venci = <fs_vzzkoko>-delfz. "FECHA VENCIMIENTO

      IF <fs_vdarl>-ranlalt1 IS NOT INITIAL.

        gw_datos-monto_ori = <fs_vdarl>-bantrag. "MONTO ORIGINAL
      ELSE.
        gw_datos-monto_ori = <fs_vzzkoko>-bzusage. "MONTO ORIGINAL

      ENDIF.

    ELSE.

      IF <fs_vdarl>-delfz IS NOT INITIAL.
        gw_datos-fecha_venci = <fs_vdarl>-delfz. "FECHA VENCIMIENTO
*      ELSE.
*        gw_datos-fecha_venci = <fs_vdarl>-dantrag. "FECHA VENCIMIENTO
      ENDIF.

      IF <fs_vdarl>-bzusage IS NOT INITIAL.
        gw_datos-monto_ori = <fs_vdarl>-bzusage. "MONTO ORIGINAL
      ELSE.
        gw_datos-monto_ori = <fs_vdarl>-bantrag. "MONTO ORIGINAL

      ENDIF.

    ENDIF.

    READ TABLE gt_zproye ASSIGNING <fs_zproye> WITH TABLE KEY zcodproyecto = <fs_vdarl>-zzproyecto.
    IF ( sy-subrc = 0 AND <fs_zproye> IS ASSIGNED ).

      gw_datos-zdescriproye = <fs_zproye>-zdescripcion."DESCRIP PROYECTO

    ENDIF.

    READ TABLE gt_zprogra ASSIGNING <fs_zprogra> WITH KEY zgsart = <fs_vdarl>-gsart
                                                          zcodprogra = <fs_vdarl>-zzprograma BINARY SEARCH.
    IF ( sy-subrc = 0 AND <fs_zprogra> IS ASSIGNED ).

      gw_datos-zzprograma = <fs_zprogra>-zdescriprog. "DESCRIP PROGRAMA

    ENDIF.

    READ TABLE gt_zproposito ASSIGNING <fs_zpropos> WITH KEY zgsart     = <fs_vdarl>-gsart
                                                             zcodprogra = <fs_vdarl>-zzprograma
                                                             zcodpropo  = <fs_vdarl>-zzproposito BINARY SEARCH.
    IF ( sy-subrc = 0 AND  <fs_zpropos> IS ASSIGNED ).

      gw_datos-zzproposito = <fs_zpropos>-zdescripcion. "DESCRIP PROPOSITO

    ENDIF.

    READ TABLE gt_zenti ASSIGNING <fs_zenti> WITH TABLE KEY zcodentidad = <fs_vdarl>-zzcodentigar.
    IF ( sy-subrc = 0 AND <fs_zenti> IS ASSIGNED ).

      gw_datos-zdescripenti = <fs_zenti>-zdescripcion. "Descripcion Cesion Garantia

    ENDIF.

    READ TABLE gt_td02t ASSIGNING <fs_td02t> WITH TABLE KEY sdtyp = <fs_vdarl>-sdtyp.
    IF ( sy-subrc = 0 AND <fs_td02t> IS ASSIGNED ).

      gw_datos-xlbez = <fs_td02t>-xlbez. "Descripcion Motivo Cancelacion

    ENDIF.

    IF <fs_vdarl>-ssonder = '03'. "COBRO JUDICIAL

      READ TABLE gt_promes ASSIGNING <fs_promes> WITH KEY bukrs = <fs_vdarl>-bukrs
                                                          kunnr = <fs_vdarl>-rdarnehm
                                                          vertn = <fs_vdarl>-ranl
                                                          zstat = '0034'.
      IF ( sy-subrc = 0 AND <fs_promes> IS ASSIGNED ).

        gw_datos-fecha_cj = <fs_promes>-fecha_reg. "FECHA COBRO JUDICIAL

        gw_datos-dias_cj  = pa_fecha - <fs_promes>-fecha_reg. "DIAS COBRO JUDICIAL

      ENDIF.

    ENDIF.

    IF <fs_vdarl>-svzweck = '04'. "PRE JUDICIAL

      READ TABLE gt_promes ASSIGNING <fs_promes> WITH KEY bukrs = <fs_vdarl>-bukrs
                                                    kunnr = <fs_vdarl>-rdarnehm
                                                    vertn = <fs_vdarl>-ranl
                                                    zstat = '0041'.

      IF ( sy-subrc = 0 AND <fs_promes> IS ASSIGNED ).

        gw_datos-fecha_precj = <fs_promes>-fecha_reg. "FECHA PRE-JUDICIAL

      ENDIF.

    ENDIF.

    READ TABLE gt_bsid_amor ASSIGNING <fs_amor> WITH KEY vertn = <fs_vdarl>-ranl BINARY SEARCH.
    IF ( sy-subrc = 0 AND <fs_amor> IS ASSIGNED ).

      gw_datos-atraso_amort = <fs_amor>-wrbtr. "PART.ABIERTAS AMORTIZACIÓN

    ENDIF.

    READ TABLE gt_bsid_int ASSIGNING <fs_int> WITH KEY vertn = <fs_vdarl>-ranl BINARY SEARCH.
    IF ( sy-subrc = 0 AND <fs_int> IS ASSIGNED ).

      gw_datos-atraso_int = <fs_int>-wrbtr. "PART.ABIERTAS INTERESES

    ENDIF.

    READ TABLE gt_bsid_mora ASSIGNING <fs_bsid_mora> WITH KEY vertn = <fs_vdarl>-ranl BINARY SEARCH.
    IF ( sy-subrc = 0 AND <fs_bsid_mora> IS ASSIGNED ).

      mc_days <fs_bsid_mora>-zfbdt pa_fecha gw_datos-diasmora. "CANTIDAD DE DIAS DE MORA

      "gw_datos-diasmora = pa_fecha - <fs_bsid_mora>-zfbdt.

      IF gw_datos-diasmora < 0.

        gw_datos-diasmora = 0.

      ENDIF.

    ELSE.

      gw_datos-diasmora = 0.

    ENDIF.

    READ TABLE gt_td10t ASSIGNING <fs_td10t> WITH TABLE KEY ssonder = <fs_vdarl>-ssonder.
    IF ( sy-subrc = 0 AND <fs_td10t> IS ASSIGNED ).

      gw_datos-estado = <fs_td10t>-xktext. "ESTADO

    ENDIF.

*--------------------------------------------------------------------*
    LOOP AT gt_garantias ASSIGNING <fs_garantias> WHERE idvaloper = <fs_vdarl>-ranl.

*--FINCA
      IF <fs_garantias>-numerofinca IS NOT INITIAL. "FINCA

        IF gw_datos-zfinca IS INITIAL.

          gw_datos-zfinca = <fs_garantias>-numerofinca.

        ELSE.

          CONCATENATE gw_datos-zfinca
                     <fs_garantias>-numerofinca
                 INTO gw_datos-zfinca SEPARATED BY ','.

        ENDIF.

      ENDIF.

*--Tipo Garantia
      IF <fs_garantias>-descrip IS NOT INITIAL.

        IF gw_datos-tipgar  IS INITIAL.

          gw_datos-tipgar  = <fs_garantias>-descrip.

        ELSE.

          CONCATENATE gw_datos-tipgar
                     <fs_garantias>-descrip
                 INTO gw_datos-tipgar  SEPARATED BY ','.

        ENDIF.

      ENDIF.

*--MONTO TASACION LOTE
      IF <fs_garantias>-mtotasterreno IS NOT INITIAL.

        IF gw_datos-zzmtaslote  IS INITIAL.

          gw_datos-zzmtaslote  = <fs_garantias>-mtotasterreno.

        ELSE.

          lv_zzmtaslote = <fs_garantias>-mtotasterreno.

          CONCATENATE gw_datos-zzmtaslote
                      lv_zzmtaslote
                 INTO gw_datos-zzmtaslote  SEPARATED BY ','.

        ENDIF.

      ENDIF.

      IF <fs_garantias>-tipgar EQ '2'.

        READ TABLE gt_tipgrado ASSIGNING <fs_tipgrado> WITH TABLE KEY codgrado = <fs_garantias>-codgrado.
        IF ( sy-subrc EQ 0 AND <fs_tipgrado> IS ASSIGNED ).

          gw_datos-zgradohip = <fs_tipgrado>-descrip."GRADO_HIPOTECA

        ENDIF.

      ELSE.

        READ TABLE gt_tipgrado ASSIGNING <fs_tipgrado> WITH TABLE KEY codgrado ='5'.
        IF ( sy-subrc EQ 0 AND <fs_tipgrado> IS ASSIGNED ).

          gw_datos-zgradohip = <fs_tipgrado>-descrip."GRADO_HIPOTECA

        ENDIF.

      ENDIF.

    ENDLOOP.

*    READ TABLE gt_garantias ASSIGNING <fs_garantias> WITH KEY idvaloper = <fs_vdarl>-ranl.
*    IF ( sy-subrc = 0 AND <fs_garantias> IS ASSIGNED ).
*
*      gw_datos-zfinca        = <fs_garantias>-numerofinca.   "FINCA
*      gw_datos-zzmtaslote    = <fs_garantias>-mtotasterreno. "MONTO TASACION LOTE
*      gw_datos-tipgar        = <fs_garantias>-descrip.       "Tipo Garantia
*
*
*      IF <fs_garantias>-tipgar EQ '2'.
*
*        READ TABLE gt_tipgrado ASSIGNING <fs_tipgrado> WITH TABLE KEY codgrado = <fs_garantias>-codgrado.
*        IF ( sy-subrc EQ 0 AND <fs_tipgrado> IS ASSIGNED ).
*
*          gw_datos-zgradohip = <fs_tipgrado>-descrip."GRADO_HIPOTECA
*
*        ENDIF.
*
*      ELSE.
*
*        READ TABLE gt_tipgrado ASSIGNING <fs_tipgrado> WITH TABLE KEY codgrado ='5'.
*        IF ( sy-subrc EQ 0 AND <fs_tipgrado> IS ASSIGNED ).
*
*          gw_datos-zgradohip = <fs_tipgrado>-descrip."GRADO_HIPOTECA
*
*        ENDIF.
*
*      ENDIF.
*
*
*    ENDIF.
*--------------------------------------------------------------------*

    READ TABLE gt_totgarant ASSIGNING <fs_totgarant> WITH TABLE KEY idvaloper = <fs_vdarl>-ranl.
    IF ( sy-subrc = 0 AND <fs_totgarant> IS ASSIGNED ) .

      gw_datos-zcant_gar = <fs_totgarant>-total. "Cantidad de Garantias Asociadas

    ENDIF.

    mc_output gw_datos-zzcontragaran.

    READ TABLE gt_contratos ASSIGNING <fs_contratos> WITH TABLE KEY codigo = gw_datos-zzcontragaran.
    IF ( sy-subrc = 0 AND  <fs_contratos> IS ASSIGNED ).

      CLEAR gw_datos-zzcontragaran.

      CONCATENATE <fs_contratos>-codigo
                  <fs_contratos>-contrato
              INTO gw_datos-zzcontragaran SEPARATED BY space.

    ENDIF.

    READ TABLE gt_pendiente ASSIGNING <fs_pendiente> WITH KEY vertn = <fs_vdarl>-ranl BINARY SEARCH.
    IF ( sy-subrc = 0 AND <fs_pendiente> IS ASSIGNED ).

      gw_datos-cuota_pen = <fs_pendiente>-wrbtr.

*--------------------------------------------------------------------*
*      READ TABLE gt_xcobrar ASSIGNING <fs_xcobrar> WITH KEY vertn = <fs_vdarl>-ranl BINARY SEARCH.
*      IF ( sy-subrc = 0 AND <fs_xcobrar> IS ASSIGNED ).
*
*        gw_datos-zplazo_rest = gw_datos-cuota_pen + <fs_xcobrar>-wrbtr.
*
*      ENDIF.
*--------------------------------------------------------------------*

    ENDIF.

    LOOP AT gt_tkopo ASSIGNING <fs_kopo> WHERE rkey1 = <fs_vdarl>-ranl.

      CASE <fs_kopo>-skoart.
        WHEN '0201'.

          gw_datos-pkond = <fs_kopo>-pkond. "TASA DE INTERÉS

        WHEN '0603'.

          gw_datos-zpor_mora = <fs_kopo>-pkond. "Tasa Interes Moratoria

        WHEN '0261'.

          gw_datos-cuota_ssegu = <fs_kopo>-bkond. "MONTO CUOTA SIN SEGURO

        WHEN '9172'.

          gw_datos-cxc_seg = <fs_kopo>-bkond. "CUENTAS X COBRAR SEGUROS

        WHEN '9002'.

          IF <fs_vdarl>-ranlalt1 IS NOT INITIAL.

            gw_datos-zzmontoaporte = <fs_kopo>-bkond. "monto aporte

          ENDIF.

        WHEN '9003'.

          IF <fs_vdarl>-ranlalt1 IS NOT INITIAL.

            gw_datos-zzmontoahorro = <fs_kopo>-bkond. "monto ahorro

          ENDIF.

        WHEN '9004'.

          IF <fs_vdarl>-ranlalt1 IS NOT INITIAL.

            gw_datos-zzbonomax = <fs_kopo>-bkond. "monto bono familiar.

          ENDIF.

      ENDCASE.


    ENDLOOP.

*    READ TABLE GT_VZZKOPO ASSIGNING <FS_VZZKOPO> WITH KEY RKEY1 = <FS_VDARL>-RANL
*                                                         SKOART = '0201' BINARY SEARCH.
*    IF ( SY-SUBRC = 0 AND <FS_VZZKOPO> IS ASSIGNED ) .
*
*      GW_DATOS-PKOND = <FS_VZZKOPO>-PKOND. "TASA DE INTERÉS
*
*    ENDIF.


*    READ TABLE GT_VZZKOPO ASSIGNING <FS_VZZKOPO> WITH KEY RKEY1 = <FS_VDARL>-RANL
*                                                         SKOART = '0603' BINARY SEARCH.
*    IF ( SY-SUBRC = 0 AND <FS_VZZKOPO> IS ASSIGNED ) .
*
*      GW_DATOS-ZPOR_MORA = <FS_VZZKOPO>-PKOND. "Tasa Interes Moratoria
*
*    ENDIF.

*    READ TABLE GT_CSINSEG ASSIGNING <FS_VZZKOPO> WITH KEY RKEY1 = <FS_VDARL>-RANL BINARY SEARCH.
*    IF ( SY-SUBRC = 0 AND <FS_VZZKOPO> IS ASSIGNED ) .
*
*      GW_DATOS-CUOTA_SSEGU = <FS_VZZKOPO>-BKOND. "MONTO CUOTA SIN SEGURO
*
*    ENDIF.

    READ TABLE gt_tpagos ASSIGNING <fs_pagos> WITH KEY ranl = <fs_vdarl>-ranl
                                                    sbewart = 'AMOR' BINARY SEARCH.
    IF ( sy-subrc = 0  AND <fs_pagos> IS ASSIGNED ).

      gw_datos-amortiza_pag = <fs_pagos>-bbwhr. "Amortización Pagado

      gw_datos-fec_ulamopag = <fs_pagos>-ddispo. "Fecha ultima amort pagados

    ENDIF.

    READ TABLE gt_tpagos ASSIGNING <fs_pagos> WITH KEY ranl = <fs_vdarl>-ranl
                                                sbewart = 'INTE' BINARY SEARCH.
    IF ( sy-subrc = 0  AND <fs_pagos> IS ASSIGNED ).

      gw_datos-int_pag = <fs_pagos>-bbwhr. "Intereses Pagados

      gw_datos-fec_ulintpag = <fs_pagos>-ddispo."FCHA_ULTIMA_INTPAGADOS

      gw_datos-diasucuota = pa_fecha - <fs_pagos>-ddispo. "Días Int.Ult Cuota Pag

    ENDIF.

    READ TABLE gt_tpagos ASSIGNING <fs_pagos> WITH KEY ranl = <fs_vdarl>-ranl
                                                sbewart = 'PAGA' BINARY SEARCH.
    IF ( sy-subrc = 0  AND <fs_pagos> IS ASSIGNED ).

      gw_datos-imora_pag = <fs_pagos>-bbwhr. "Int.Moratorios Pagados

    ENDIF.

    IF <fs_vdarl>-sstati <> '099'.

      READ TABLE gt_proxcuota ASSIGNING <fs_proxcuota> WITH KEY ranl = <fs_vdarl>-ranl.
      IF ( sy-subrc = 0  AND <fs_proxcuota> IS ASSIGNED ) .

        gw_datos-fec_prox_cuota = <fs_proxcuota>-ddispo. "FECHA VENCIMIENTO PROXIMA CUOTA

      ENDIF.

    ENDIF.


    READ TABLE gt_contrato ASSIGNING <fs_contrato> WITH KEY ranl = <fs_vdarl>-ranl.
    IF ( sy-subrc = 0 AND <fs_contrato> IS ASSIGNED ).

      gw_datos-saldo_credito = <fs_contrato>-briwr. "Saldo Monto Crédito Base

    ENDIF.

    LOOP AT gt_sus_acum ASSIGNING <fs_int> WHERE vertn = <fs_vdarl>-ranl.

      IF <fs_int>-kunnr = 'INT.SUS'.

        gw_datos-int_sacumula = <fs_int>-wrbtr. "INTERESES EN SUSPENSO.
      ELSE.
        gw_datos-int_acumula = <fs_int>-wrbtr. "INTERESES EACUMULADOS.

      ENDIF.

    ENDLOOP.


*    READ TABLE gt_sus_acum ASSIGNING <fs_int> WITH KEY vertn = <fs_vdarl>-ranl.
*    IF ( sy-subrc = 0 AND <fs_int> IS ASSIGNED ).
*
*      IF <fs_int>-kunnr = 'INT.SUS'.
*
*        gw_datos-int_sacumula = <fs_int>-wrbtr. "INTERESES EN SUSPENSO.
*
*      ELSE.
*
*        gw_datos-int_acumula = <fs_int>-wrbtr. "INTERESES EACUMULADOS.
*
*      ENDIF.
*
*    ENDIF.


*--------------------------------------------------------------------*
    READ TABLE gt_but000 ASSIGNING <fs_but000> WITH TABLE KEY partner = gw_datos-rdarnehm.
    IF ( sy-subrc = 0 AND <fs_but000> IS ASSIGNED ).

      CASE <fs_but000>-type.
        WHEN 1. "Persona

          CONCATENATE <fs_but000>-name_first
                      <fs_but000>-name_last
                      <fs_but000>-name_lst2
                 INTO gw_datos-rdarnehm_name SEPARATED BY space. "NOMBRE INTERL.COMERCIAL

        WHEN 2. "Empresa

          CONCATENATE <fs_but000>-name_org1
                      <fs_but000>-name_org2
                      <fs_but000>-name_org3
                 INTO gw_datos-rdarnehm_name SEPARATED BY space. "NOMBRE INTERL.COMERCIAL

        WHEN 3. "Organizacion
      ENDCASE.

      READ TABLE gt_but0id ASSIGNING <fs_but0id> WITH TABLE KEY partner = <fs_but000>-partner.
      IF ( sy-subrc = 0 AND <fs_but0id> IS ASSIGNED ).

        gw_datos-id_number = <fs_but0id>-idnumber. "IDENTIFICACIÓN INTERL.COMERCIAL

        LOOP AT gt_but021_fs ASSIGNING <fs_but021> WHERE partner  = <fs_but000>-partner AND adr_kind = '0001'.

          READ TABLE gt_adrc ASSIGNING <fs_adrc> WITH TABLE KEY addrnumber = <fs_but021>-addrnumber.
          IF ( sy-subrc = 0 AND <fs_adrc> IS ASSIGNED ).

            CONCATENATE <fs_adrc>-street
                        <fs_adrc>-str_suppl3
                        <fs_adrc>-location
                   INTO gw_datos-direccion_not SEPARATED BY space. "direccion notificar

            gw_datos-rdarnehm_dir = gw_datos-direccion_not.

            gw_datos-zona_trans = <fs_adrc>-transpzone. "Zona de Transporte

            CASE gw_datos-zona_trans(1).
              WHEN '1'.
                gv_provincia = 'SAN JOSÉ' .
              WHEN '2'.
                gv_provincia = 'ALAJUELA'.
              WHEN '3'.
                gv_provincia = 'CARTAGO'.
              WHEN '4'.
                gv_provincia = 'HEREDIA'.
              WHEN '5'.
                gv_provincia = 'GUANACASTE'.
              WHEN '6'.
                gv_provincia = 'PUNTARENAS'.
              WHEN '7'.
                gv_provincia = 'LIMÓN'.
            ENDCASE.

            READ TABLE gt_tzont ASSIGNING <fs_tzont> WITH KEY zone1 = gw_datos-zona_trans BINARY SEARCH.
            IF ( sy-subrc = 0 AND <fs_tzont> IS ASSIGNED ).

              CONCATENATE gv_provincia
                          '-'
                          <fs_tzont>-vtext
                     INTO gw_datos-direccion.

            ENDIF.

            CLEAR: gv_flag_tel.

            gv_tabix = 1.
            LOOP AT gt_adr2 ASSIGNING <fs_adr2> WHERE addrnumber = <fs_adrc>-addrnumber.

              gv_flag_tel = 'X'.

              REPLACE ALL OCCURRENCES OF '-' IN <fs_adr2>-tel_number WITH space.

              CONDENSE <fs_adr2>-tel_number NO-GAPS.

              CASE gv_tabix.
                WHEN 1.
                  gw_datos-tel_1 = <fs_adr2>-tel_number.
                WHEN 2.
                  gw_datos-tel_2 = <fs_adr2>-tel_number.
                WHEN 3.
                  gw_datos-tel_3 = <fs_adr2>-tel_number.
                WHEN 4.
                  gw_datos-tel_4 = <fs_adr2>-tel_number.
                WHEN 5.
                  gw_datos-tel_5 = <fs_adr2>-tel_number.
                WHEN 6.
                  gw_datos-tel_6 = <fs_adr2>-tel_number.
                WHEN OTHERS.
                  EXIT.
              ENDCASE.

              ADD 1 TO gv_tabix.

            ENDLOOP.

          ENDIF.

        ENDLOOP.

        IF gv_flag_tel IS INITIAL.

          LOOP AT gt_but021_fs ASSIGNING <fs_but021> WHERE partner  = <fs_but000>-partner AND adr_kind <> '0001'.

            READ TABLE gt_adrc ASSIGNING <fs_adrc> WITH TABLE KEY addrnumber = <fs_but021>-addrnumber.
            IF ( sy-subrc = 0 AND <fs_adrc> IS ASSIGNED ).

              gv_tabix = 1.
              LOOP AT gt_adr2 ASSIGNING <fs_adr2> WHERE addrnumber = <fs_adrc>-addrnumber.

                gv_flag_tel = 'X'.

                REPLACE ALL OCCURRENCES OF '-' IN <fs_adr2>-tel_number WITH space.

                CONDENSE <fs_adr2>-tel_number NO-GAPS.

                CASE gv_tabix.
                  WHEN 1.
                    gw_datos-tel_1 = <fs_adr2>-tel_number.
                  WHEN 2.
                    gw_datos-tel_2 = <fs_adr2>-tel_number.
                  WHEN 3.
                    gw_datos-tel_3 = <fs_adr2>-tel_number.
                  WHEN 4.
                    gw_datos-tel_4 = <fs_adr2>-tel_number.
                  WHEN 5.
                    gw_datos-tel_5 = <fs_adr2>-tel_number.
                  WHEN 6.
                    gw_datos-tel_6 = <fs_adr2>-tel_number.
                  WHEN OTHERS.
                    EXIT.
                ENDCASE.

                ADD 1 TO gv_tabix.

              ENDLOOP.

            ENDIF.

          ENDLOOP.

        ENDIF.

      ENDIF.


*      READ TABLE gt_but0id ASSIGNING <fs_but0id> WITH TABLE KEY partner = <fs_but000>-partner.
*      IF ( sy-subrc = 0 AND <fs_but0id> IS ASSIGNED ).
*
*        gw_datos-id_number = <fs_but0id>-idnumber. "IDENTIFICACIÓN INTERL.COMERCIAL
*
*        LOOP AT gt_but021_fs ASSIGNING <fs_but021> WHERE partner  = <fs_but000>-partner.
*
*          READ TABLE gt_adrc ASSIGNING <fs_adrc> WITH TABLE KEY addrnumber = <fs_but021>-addrnumber.
*
*          IF ( sy-subrc = 0 AND <fs_adrc> IS ASSIGNED ).
*
*            CASE <fs_but021>-adr_kind.
*              WHEN '0001'.
*
*                CONCATENATE <fs_adrc>-street
*                            <fs_adrc>-str_suppl3
*                            <fs_adrc>-location
*                       INTO gw_datos-direccion_not SEPARATED BY space. "direccion notificar
*
*                gw_datos-rdarnehm_dir = gw_datos-direccion_not.
*
*              WHEN 'XXDEFAULT'.
*
*                CONCATENATE <fs_adrc>-street
*                            <fs_adrc>-str_suppl3
*                            <fs_adrc>-location
*                       INTO gw_datos-rdarnehm_dir SEPARATED BY space. "direccion INTER COMERCIAL
*
*            ENDCASE.
*
*            gw_datos-zona_trans = <fs_adrc>-transpzone. "Zona de Transporte
*
*            CASE gw_datos-zona_trans(1).
*              WHEN '1'.
*                gv_provincia = 'SAN JOSÉ' .
*              WHEN '2'.
*                gv_provincia = 'ALAJUELA'.
*              WHEN '3'.
*                gv_provincia = 'CARTAGO'.
*              WHEN '4'.
*                gv_provincia = 'HEREDIA'.
*              WHEN '5'.
*                gv_provincia = 'GUANACASTE'.
*              WHEN '6'.
*                gv_provincia = 'PUNTARENAS'.
*              WHEN '7'.
*                gv_provincia = 'LIMÓN'.
*            ENDCASE.
*
*            READ TABLE gt_tzont ASSIGNING <fs_tzont> WITH KEY zone1 = gw_datos-zona_trans BINARY SEARCH.
*            IF ( sy-subrc = 0 AND <fs_tzont> IS ASSIGNED ).
*
*              CONCATENATE gv_provincia
*                          '-'
*                          <fs_tzont>-vtext
*                     INTO gw_datos-direccion.
*
*            ENDIF.
*
*            gv_tabix = 1.
*            LOOP AT gt_adr2 ASSIGNING <fs_adr2> WHERE addrnumber = <fs_adrc>-addrnumber.
*
*              REPLACE ALL OCCURRENCES OF '-' IN <fs_adr2>-tel_number WITH space.
*
*              CONDENSE <fs_adr2>-tel_number NO-GAPS.
*
*              CASE gv_tabix.
*                WHEN 1.
*                  gw_datos-tel_1 = <fs_adr2>-tel_number.
*                WHEN 2.
*                  gw_datos-tel_2 = <fs_adr2>-tel_number.
*                WHEN 3.
*                  gw_datos-tel_3 = <fs_adr2>-tel_number.
*                WHEN 4.
*                  gw_datos-tel_4 = <fs_adr2>-tel_number.
*                WHEN 5.
*                  gw_datos-tel_5 = <fs_adr2>-tel_number.
*                WHEN 6.
*                  gw_datos-tel_6 = <fs_adr2>-tel_number.
*                WHEN OTHERS.
*                  EXIT.
*              ENDCASE.
*
*              ADD 1 TO gv_tabix.
*
*            ENDLOOP.
*
*          ENDIF.
*
*        ENDLOOP.
*
*      ENDIF.

*      READ TABLE gt_but021_fs ASSIGNING <fs_but021> WITH TABLE KEY partner  = <fs_but000>-partner
*                                                                   adr_kind = '0001'.
*      IF ( sy-subrc = 0 AND <fs_but021> IS ASSIGNED ).
*
*        READ TABLE gt_adrc ASSIGNING <fs_adrc> WITH TABLE KEY addrnumber = <fs_but021>-addrnumber.
*        IF ( sy-subrc = 0 AND <fs_adrc> IS ASSIGNED ).
*
*          CONCATENATE <fs_adrc>-street
*                      <fs_adrc>-str_suppl3
*                      <fs_adrc>-location
*                 INTO gw_datos-direccion_not SEPARATED BY space. "direccion notificar
*
*          gw_datos-zona_trans = <fs_adrc>-transpzone. "Zona de Transporte
*
*          CASE gw_datos-zona_trans(1).
*            WHEN '1'.
*              gv_provincia = 'SAN JOSÉ' .
*            WHEN '2'.
*              gv_provincia = 'ALAJUELA'.
*            WHEN '3'.
*              gv_provincia = 'CARTAGO'.
*            WHEN '4'.
*              gv_provincia = 'HEREDIA'.
*            WHEN '5'.
*              gv_provincia = 'GUANACASTE'.
*            WHEN '6'.
*              gv_provincia = 'PUNTARENAS'.
*            WHEN '7'.
*              gv_provincia = 'LIMÓN'.
*          ENDCASE.
*
*
*
*        ENDIF.
*
*      ENDIF.

*      READ TABLE gt_but021_fs ASSIGNING <fs_but021> WITH TABLE KEY partner  = <fs_but000>-partner
*                                                                   adr_kind = 'XXDEFAULT'.
*      IF ( sy-subrc = 0 AND <fs_but021> IS ASSIGNED ).
*
*        READ TABLE gt_adrc ASSIGNING <fs_adrc> WITH TABLE KEY addrnumber = <fs_but021>-addrnumber.
*        IF ( sy-subrc = 0 AND <fs_adrc> IS ASSIGNED ).
*
*          CONCATENATE <fs_adrc>-street
*                      <fs_adrc>-str_suppl3
*                      <fs_adrc>-location
*                 INTO gw_datos-rdarnehm_dir SEPARATED BY space. "direccion INTER COMERCIAL
*
*          gw_datos-zona_trans = <fs_adrc>-transpzone. "Zona de Transporte
*
*
*        ENDIF.
*
*      ELSE.
*
*        gw_datos-rdarnehm_dir = gw_datos-direccion_not. "direccion INTER COMERCIAL
*
*      ENDIF.


      READ TABLE gt_but050 ASSIGNING <fs_but050> WITH TABLE KEY partner1 = <fs_but000>-partner.
      IF ( sy-subrc = 0 AND <fs_but050> IS ASSIGNED ).

        UNASSIGN <fs_but000>.

        READ TABLE gt_but000 ASSIGNING <fs_but000> WITH TABLE KEY partner = <fs_but050>-partner2.
        IF ( sy-subrc = 0 AND <fs_but000> IS ASSIGNED ).

          CASE <fs_but000>-type.
            WHEN 1. "Persona

              CONCATENATE <fs_but000>-name_first
                          <fs_but000>-name_last
                          <fs_but000>-name_lst2
                     INTO gw_datos-zzoficial SEPARATED BY space. "Oficial Cobro

            WHEN 2. "Empresa

              CONCATENATE <fs_but000>-name_org1
                          <fs_but000>-name_org2
                          <fs_but000>-name_org3
                     INTO gw_datos-zzoficial SEPARATED BY space. "Oficial Cobro

            WHEN 3. "Organizacion
          ENDCASE.

        ENDIF.

      ENDIF.

    ENDIF.

    READ TABLE gt_but000 ASSIGNING <fs_but000> WITH TABLE KEY partner = gw_datos-zzfiscal.
    IF ( sy-subrc = 0 AND <fs_but000> IS ASSIGNED ).

      CASE <fs_but000>-type.
        WHEN 1. "Persona

          CONCATENATE <fs_but000>-name_first
                      <fs_but000>-name_last
                      <fs_but000>-name_lst2
                 INTO gw_datos-zzfiscal_txt SEPARATED BY space. "Descripcion Profesional
        WHEN 2. "Empresa

          CONCATENATE <fs_but000>-name_org1
                      <fs_but000>-name_org2
                      <fs_but000>-name_org3
                 INTO gw_datos-zzfiscal_txt SEPARATED BY space. "Descripcion Profesional
        WHEN 3. "Organizacion
      ENDCASE.

    ENDIF.

    READ TABLE gt_but000 ASSIGNING <fs_but000> WITH TABLE KEY partner = gw_datos-zzorgrecau.
    IF ( sy-subrc = 0 AND <fs_but000> IS ASSIGNED ).

      CASE <fs_but000>-type.
        WHEN 1. "Persona

          CONCATENATE <fs_but000>-name_first
                      <fs_but000>-name_last
                      <fs_but000>-name_lst2
                 INTO gw_datos-zzorgrecau_txt SEPARATED BY space. "Descripcion Org Recaudadora
        WHEN 2. "Empresa

          CONCATENATE <fs_but000>-name_org1
                      <fs_but000>-name_org2
                      <fs_but000>-name_org3
                 INTO gw_datos-zzorgrecau_txt SEPARATED BY space. "Descripcion Org Recaudadora
        WHEN 3. "Organizacion
      ENDCASE.

    ENDIF.

    READ TABLE gt_but000 ASSIGNING <fs_but000> WITH TABLE KEY partner = gw_datos-zzorgcolab.
    IF ( sy-subrc = 0 AND <fs_but000> IS ASSIGNED ).

      CASE <fs_but000>-type.
        WHEN 1. "Persona

          CONCATENATE <fs_but000>-name_first
                      <fs_but000>-name_last
                      <fs_but000>-name_lst2
                 INTO gw_datos-zzorgcolab_txt SEPARATED BY space. "Descripcion Org Recaudadora
        WHEN 2. "Empresa

          CONCATENATE <fs_but000>-name_org1
                      <fs_but000>-name_org2
                      <fs_but000>-name_org3
                 INTO gw_datos-zzorgcolab_txt SEPARATED BY space. "Descripcion Org Recaudadora
        WHEN 3. "Organizacion
      ENDCASE.

    ENDIF.

    READ TABLE gt_but000 ASSIGNING <fs_but000> WITH TABLE KEY partner = gw_datos-zzanalista.
    IF ( sy-subrc = 0 AND <fs_but000> IS ASSIGNED ).

      CASE <fs_but000>-type.
        WHEN 1. "Persona

          CONCATENATE <fs_but000>-name_first
                      <fs_but000>-name_last
                      <fs_but000>-name_lst2
                 INTO gw_datos-zzanalista_txt SEPARATED BY space. "Descripcion Org Recaudadora
        WHEN 2. "Empresa

          CONCATENATE <fs_but000>-name_org1
                      <fs_but000>-name_org2
                      <fs_but000>-name_org3
                 INTO gw_datos-zzanalista_txt SEPARATED BY space. "Descripcion Org Recaudadora
        WHEN 3. "Organizacion
      ENDCASE.

    ENDIF.

    MOVE-CORRESPONDING gw_datos TO gw_zcartera.

    APPEND gw_zcartera TO gt_zcartera[].

    mc_date gw_datos-zzdesemadel.
    mc_date gw_datos-zzdesemclreal.
    mc_date gw_datos-zzdesemcompl.
    mc_date gw_datos-fecha_reporte.
    mc_date gw_datos-fec_ulintpag.
    mc_date gw_datos-fec_ulamopag.
    mc_date gw_datos-fec_prox_cuota.
    mc_date gw_datos-fecha_precj.
    mc_date gw_datos-fecha_cj.
    mc_date gw_datos-fecha_venci.
    mc_date gw_datos-zzfeformbono.
    mc_date gw_datos-zzfeboleta.
    mc_date gw_datos-zzfenpconstruc.
    mc_date gw_datos-zzriliquid.
    mc_date gw_datos-zzfeembono.
    mc_date gw_datos-zzfecobono.
    mc_date gw_datos-zzfepabono.
    mc_date gw_datos-zzfeanbono.
    mc_date gw_datos-zzfeaprobanhvi.
    mc_date gw_datos-zzfe_asig_fiscal.

    APPEND gw_datos TO gt_datos[].

  ENDLOOP.

*  PERFORM f_convert_data.

  PERFORM f_show_alv USING gt_datos[]
                           space.

  IF pa_file = 'X'.

    PERFORM f_save_file.

  ENDIF.

  IF pa_alv = 'X'.

*... §8 display the table
    gt_table->display( ).

  ENDIF.

  IF pa_tab = 'X' AND gt_zcartera[] IS NOT INITIAL.

    MODIFY zlmtcartera FROM TABLE gt_zcartera[].

    COMMIT WORK.

  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  F_SHOW_ALV
*&---------------------------------------------------------------------*
FORM f_show_alv USING pt_table
                       pv_name TYPE string.

  DATA: l_text TYPE lvc_title.
  "l_icon TYPE string.

*... §2 create an ALV table
  TRY.
      cl_salv_table=>factory(
        "EXPORTING
          "r_container    = gr_container
          "container_name = 'CONTAINER'
        IMPORTING
          r_salv_table   = gt_table "gr_table
        CHANGING
          t_table        = pt_table ). "gt_totest ).
    CATCH cx_salv_msg.
  ENDTRY.

*save variant
  g_layout     = gt_table->get_layout( ).
  g_key-report = sy-repid.
  g_layout->set_key( g_key ).

  g_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

*Para los botones en el status
  g_functions = gt_table->get_functions( ).
  g_functions->set_all( abap_true ).

*Para poner color a una columna
  g_columns = gt_table->get_columns( ).
  g_columns->set_optimize( 'X' ).

  CLEAR: l_text.

  l_text = 'Reporte Zcartera'.

*  case 'X'.
*    when pa_r1.
*      l_text = 'Reporte Cancelaciones'.
*    when pa_r2.
*      l_text = 'Reporte Abonos Extraordinarios'.
*    when pa_r3.
*      l_text = 'Reporte Amortizaciónes'.
*  endcase.


*Para mostar el titulo del alv
  g_dsp = gt_table->get_display_settings( ).
  g_dsp->set_list_header( l_text ).

  mc_columna 'BUKRS'            'Sociedad'                         '' '' ''.
  mc_columna 'GSART'            'Clase producto'                   '' '' ''.
  mc_columna 'STITEL'           'Clase prestamo'                   '' '' ''.
  mc_columna 'ZZDESEMADEL'      'Fecha Adelanto Desembolso'        '' '' ''.
  mc_columna 'ZZDESEMCLREAL'    'Fecha desembolso completo'        '' '' ''.
  mc_columna 'ZZDESEMCOMPL'     'Fecha Desembolso completo'        '' '' ''.
  mc_columna 'RANL'             'Contrato'                         '' '' ''.
  mc_columna 'RDARNEHM'         'BP Cliente'                       '' '' ''.
  mc_columna 'RDARNEHM_NAME'    'Nombre Cliente'                   '' '' ''.
  mc_columna 'FECHA_REPORTE'    'Fecha del Reporte'                '' '' ''.
  mc_columna 'ID_NUMBER'        'Cedula Cliente'                   '' '' ''.
  mc_columna 'SONDST'           'Categoria'                        '' '' ''.
  mc_columna 'DIASMORA'         'Dias de Mora'                     '' '' ''.
  mc_columna 'MONTO_ORI'        'Monto Original'                   '' '' ''.
  mc_columna 'CUOTA_PEN'        'Cuotas Pendientes'                '' '' ''.
  mc_columna 'CUOTA_SSEGU'      'Cuota Sin Seguro'                 '' '' ''.
  mc_columna 'CXC_SEG'          'Cuenta por Cobrar Seguros'        '' '' 'X'.
  mc_columna 'SALDO_CREDITO'    'Saldo Monto Credito Base'         '' '' ''.
  mc_columna 'INT_ACUMULA'      'Intereses acumulados'             '' '' ''.
  mc_columna 'INT_SACUMULA'     'Intereses en suspenso'            '' '' ''.
  mc_columna 'INT_NODEVENGA'    'Intereses no devengados'          '' '' ''.
  mc_columna 'ATRASO_AMORT'     'Partidas Abiertas Amortizacion'   '' '' ''.
  mc_columna 'ATRASO_INT'       'Partidas Abiertas Intereses'      '' '' ''.
  mc_columna 'FEC_ULINTPAG'     'Fecha Ultimos Intereses Pagados'  '' '' ''.
  mc_columna 'FEC_ULAMOPAG'     'Fecha Ultima amortizacion Pagada' '' '' ''.
  mc_columna 'FEC_PROX_CUOTA'   'Fecha vencimiento proxima cuota'  '' '' ''.
  mc_columna 'ESTADO'           'Estado cartera'                   '' '' ''.
  mc_columna 'ZZSUSPENDIDO'     'Suspendido'                       '' '' ''.
  mc_columna 'SVZWECK'          'Estado Pre Judicial'              '' '' ''.
  mc_columna 'FECHA_PRECJ'      'Fecha Pre Judicial'               '' '' ''.
  mc_columna 'FECHA_CJ'         'Fecha cobro judicial'             '' '' ''.
  mc_columna 'DIAS_CJ'          'Dias Cobro judicial'              '' '' ''.
  mc_columna 'ZZPLAZO'          'Plazo en meses'                   '' '' ''.
  mc_columna 'ZPLAZO_REST'      'Plazo restante meses'             '' '' ''.
  mc_columna 'ZPOR_MORA'        'Tasa Interes Moratoria'           '' '' ''.
  mc_columna 'FECHA_VENCI'      'Fecha Vencimiento Prestamo'       '' '' ''.
  mc_columna 'AMORTIZA_PAG'     'Amortizacion Pagado'              '' '' ''.
  mc_columna 'INT_PAG'          'Intereses Pagados'                '' '' ''.
  mc_columna 'IMORA_PAG'        'Intereses Moratorios Pagados'     '' '' ''.
  mc_columna 'DIRECCION'        'Direccion'                        '' '' ''.
  mc_columna 'RDARNEHM_DIR'     'Direccion Cliente'                '' '' ''.
  mc_columna 'DIRECCION_NOT'    'Direccion Cliente para Notificar' '' '' ''.
  mc_columna 'ZZORGRECAU'       'BP Socio Recaudador'              '' '' ''.
  mc_columna 'ZZORGRECAU_TXT'   'Socio Recaudador'                 '' '' ''.
  mc_columna 'ZZOFICIAL'        'Oficial Cobro'                    '' '' ''.
  mc_columna 'ZZCODENTIGAR'     'Cesion Garantia'                  '' '' ''.
  mc_columna 'ZDESCRIPENTI'     'Descripcion Cesion Garantia'      '' '' ''.
  mc_columna 'ZZCONTRAGARAN'    'Contrato Garantia'                '' '' ''.
  mc_columna 'ZZPROYECTO'       'Codigo Proyecto'                  '' '' ''.
  mc_columna 'ZDESCRIPROYE'     'Nombre Proyecto'                  '' '' ''.
  mc_columna 'TEL_1'            'Telefono 1'                       '' '' ''.
  mc_columna 'TEL_2'            'Telefono 2'                       '' '' ''.
  mc_columna 'TEL_3'            'Telefono 3'                       '' '' ''.
  mc_columna 'TEL_4'            'Telefono 4'                       '' '' ''.
  mc_columna 'TEL_5'            'Telefono 5'                       '' '' ''.
  mc_columna 'TEL_6'            'Telefono 6'                       '' '' ''.
  mc_columna 'ZZFEFORMBONO'     'Fecha Formalizacion'              '' '' ''.
  mc_columna 'ZZORGCOLAB'       'BP Socio Colocador'               '' '' ''.
  mc_columna 'ZZORGCOLAB_TXT'   'Socio Colocador'                  '' '' ''.
  mc_columna 'DIASUCUOTA'       'Dias Int Ultima Cuota Pagada'     '' '' ''.
  mc_columna 'ZCANT_GAR'        'Cantidad Garantias Asociadas'     '' '' ''.
  mc_columna 'ZZMTASLOTE'       'Tasacion Lote'                    '' '' ''.
  mc_columna 'ZZTASVIVIENDA'    'Tasacion Vivienda'                '' '' ''.
  mc_columna 'PRECONGASTOS'     'Presupuesto con Gastos'           '' '' ''.
  mc_columna 'ZZANALISTA'       'BP Analista'                      '' '' ''.
  mc_columna 'ZZANALISTA_TXT'   'Analista'                         '' '' ''.
  mc_columna 'ZFINCA'           'Finca'                            '' '' ''.
  mc_columna 'ZGRADOHIP'        'Grado Hipoteca'                   '' '' ''.
  mc_columna 'TIPMITRIESG'      'Tipo Mitigador Riesgo'            '' '' ''.
  mc_columna 'TIPGAR'           'Tipo Garantia'                    '' '' ''.
  mc_columna 'ZZPROGRAMA'       'Programa'                         '' '' ''.
*mc_columna 'ZDESCRIPROG'      'Desc. Programa'                    '' '' ''.
  mc_columna 'ZZPROPOSITO'      'Proposito'                        '' '' ''.
*mc_columna 'ZDESCRIPROP'      'Desc. Programa'                    '' '' ''.
  mc_columna 'ZZFEBOLETA'       'Fecha Boleta Amarilla'            '' '' ''.
  mc_columna 'ZZFISCAL'         'BP Fiscal'                        '' '' ''.
  mc_columna 'ZZFISCAL_TXT'     'Fiscal'                           '' '' ''.
  mc_columna 'SDTYP'            'Codigo Motivo Cancelacion'        '' '' ''.
  mc_columna 'XLBEZ'            'Motivo Cancelacion'               '' '' ''.
  mc_columna 'ZZBONOMAX'        'Monto Bono Familiar'              '' '' ''.
  mc_columna 'ZZCREDMAX'        'Monto Credito Maximo'             '' '' ''.
  mc_columna 'ZZINGREBRU'       'Monto Ingreso Bruto'              '' '' ''.
  mc_columna 'ZZINGRENET'       'Monto Ingreso Neto'               '' '' ''.
  mc_columna 'ZZESTRATO'        'Monto Estrato'                    '' '' ''.
  mc_columna 'ZZPRESUPUES'      'Monto Presupuesto'                '' '' ''.
  mc_columna 'ZZTASAVIVI'       'Monto Tasacion Vivienda'          '' '' ''.
  mc_columna 'ZZMCOMPVENT'      'Monto Compra Venta'               '' '' ''.
  mc_columna 'ZZCUOTAING'       'Monto Relacion Cuota Ingreso'     '' '' ''.
  mc_columna 'ZZINTSOCIAL'      'Indicador Interes Social'         '' '' ''.
  mc_columna 'ZZPATRIMON'       'Indicador Patrimonio'             '' '' ''.
  mc_columna 'ZZSEGREGA'        'Indicador Segregacion'            '' '' ''.
  mc_columna 'ZZCODENTIREC'     'Codigo Entidad Fuente Recursos'   '' '' ''.
  mc_columna 'ZZCONTRARECUR'    'Numero Contrato Fuente Recursos'  '' '' ''.
  mc_columna 'ZZTRASOCIAL'      'BP Trabajador Social'             '' '' ''.
  mc_columna 'ZZPRORESPON'      'BP Profesional Responsable'       '' '' ''.
  mc_columna 'ZZNOTARIO'        'BP Notario'                       '' '' ''.
  mc_columna 'ZZNPCONSTRUC'     'Numero Permiso Constructivo'      '' '' ''.
  mc_columna 'ZZFENPCONSTRUC'   'Fecha Permiso Constructivo'       '' '' ''.
  mc_columna 'ZZRILIQUID'       'Fecha Recibo Informe Liquidacion' '' '' ''.
  mc_columna 'ZZNUMBONO'        'Numero Bono'                      '' '' ''.
  mc_columna 'ZZFEEMBONO'       'Fecha Emision Bono'               '' '' ''.
  mc_columna 'ZZFECOBONO'       'Fecha Cobro Bono'                 '' '' ''.
  mc_columna 'ZZFEPABONO'       'Fecha Pago Bono'                  '' '' ''.
  mc_columna 'ZZFEANBONO'       'Fecha Anulacion Bono'             '' '' ''.
  mc_columna 'ZZFEAPROBANHVI'   'Fecha Aprobacion Banhvi'          '' '' ''.
  mc_columna 'ZZOFIBONO'        'Numero Oficio Bono'               '' '' ''.
  mc_columna 'ZZNUACTA'         'Numero Acta'                      '' '' ''.
  mc_columna 'ZZN_RE_APORTE'    'Numero Deposito Recibo Aporte'    '' '' ''.
  mc_columna 'ZZN_RE_AHORRO'    'Numero Deposito Recibo Ahorro'    '' '' ''.
  mc_columna 'ZZN_RE_ESTSOCIAL' 'Numero Recibo Estudio Social'     '' '' ''.
  mc_columna 'ZZN_RE_AVALUO'    'Numero Deposito Recibo Avaluo'    '' '' ''.
  mc_columna 'ZZPRESINGASTOS'   'Presupuesto Construc sin Gasto'   '' '' ''.
  mc_columna 'ZZPRECONGASTOS'   'Presupuesto Construc con Gasto'    '' '' ''.
  mc_columna 'ZZMONTAVALUO'     'Monto Avaluo Pagar Cliente'        '' '' ''.
  mc_columna 'ZZTASLOTE'        'Monto Tasado Lote'                 '' '' ''.
  mc_columna 'ZZMONTOAPORTE'    'Monto Aporte'                      '' '' ''.
  mc_columna 'ZZMONT_ESTSOCIAL' 'Monto Estudio Social'              '' '' ''.
  mc_columna 'ZZRESTDEDUC'      'Deducciones Restantes Desembolso'  '' '' ''.
  mc_columna 'ZZHON_PROF_RE'    'Honorarios Profesional Responsable' '' '' ''.
  mc_columna 'ZZFE_ASIG_FISCAL' 'Fecha Asignacion Fiscal'           '' '' ''.
  mc_columna 'ZZMONTOAHORRO'    'Monto Ahorro'                      '' '' ''.
  mc_columna 'SSTATI'           'Status'                            '' '' ''.
  mc_columna 'RANLALT1'         'Numero Alternativo 1'              '' '' ''.
* mc_columna 'SANTWHR'          'Moneda'                            '' '' ''.


  IF pa_file = 'X'.

    DATA: gw_nombre TYPE string,
          lv_column TYPE salv_t_column_ref.

    FIELD-SYMBOLS: <fs_col3> TYPE salv_s_column_ref,
                   <fs_ls> TYPE ANY TABLE ,
                   <fs_ws> TYPE any .


    lv_column = g_columns->get( ).

    ASSIGN lv_column TO  <fs_ls>  .

    REFRESH: gt_field[].

    LOOP AT <fs_ls> ASSIGNING <fs_ws>.

      ASSIGN <fs_ws> TO <fs_col3>.

      CLEAR gw_field.

      gw_field-nombre  = <fs_col3>-r_column->get_long_text( ) .

      APPEND gw_field TO gt_field[].

    ENDLOOP.

  ENDIF.

* Revisar lo del PROGRAMA Y SU DESCRIPCION
*  PERFORM f_header.

*  IF pa_alv = 'X'.
*
**... §8 display the table
*    gt_table->display( ).
*
*  ENDIF.


ENDFORM.                    "sb_show_alv


*&---------------------------------------------------------------------*
*&      Form  F_PLAZO_RESTANTE
*&---------------------------------------------------------------------*
FORM f_plazo_restante .

  TYPES: BEGIN OF ty_bsid_count,
          kunnr TYPE kunnr,
          vertn TYPE ranl,
          total TYPE i,
         END   OF ty_bsid_count,

         BEGIN OF ty_planif,
           ranl TYPE ranl,
           total TYPE i,
         END   OF ty_planif.

  DATA: gt_bsid_count TYPE HASHED TABLE OF ty_bsid_count WITH UNIQUE KEY vertn,
        gt_planif     TYPE HASHED TABLE OF ty_planif WITH UNIQUE KEY ranl,
        gv_conta      TYPE i.

  FIELD-SYMBOLS: <fs_count>  TYPE ty_bsid_count,
                 <fs_planif> TYPE ty_planif.

  "cuotas contabilizadas
  SELECT kunnr vertn COUNT( * )
    INTO TABLE gt_bsid_count
    FROM bsid
   WHERE vertn IN so_ranl
     AND vbewa = '0110'
   GROUP BY kunnr vertn.

  "SORT gt_bsid_count BY vertn kunnr.

  "cuotas planificadas
  SELECT ranl COUNT( * )
    INTO TABLE gt_planif
    FROM vissr_vdbevi
   WHERE bukrs = pa_bukrs
     AND ranl IN so_ranl
     AND sbewart IN ('0125', '0120' )
   GROUP BY ranl.

  SORT: gt_vdarl  BY ranl.

  LOOP AT gt_vdarl ASSIGNING <fs_vdarl>.

    CLEAR gv_conta.

    READ TABLE gt_bsid_count ASSIGNING <fs_count> WITH TABLE KEY vertn = <fs_vdarl>-ranl.
    IF ( sy-subrc = 0 AND <fs_count> IS ASSIGNED  ).

      gv_conta = <fs_count>-total.

    ENDIF.

    READ TABLE gt_planif ASSIGNING <fs_planif> WITH TABLE KEY ranl = <fs_vdarl>-ranl.
    IF ( sy-subrc = 0 AND <fs_planif> IS ASSIGNED ).

      <fs_planif>-total = <fs_planif>-total - gv_conta.

      <fs_vdarl>-zzplazo = <fs_vdarl>-zzplazo - <fs_planif>-total.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_PLAZO_RESTANTE


*&---------------------------------------------------------------------*
*&      Form  F_SAVE_FILE
*&---------------------------------------------------------------------*
FORM f_save_file .

  DATA: lv_ruta LIKE rlgrap-filename.


  CONCATENATE pa_path
              '\'
              'Cartera'
              '-'
              sy-datum "pa_fecha
              '-'
              sy-uzeit
              '.xls'
          INTO lv_ruta.

  PERFORM f_convert_to_texto TABLES gt_datos gt_field.

  PERFORM f_export_data TABLES ts_texto USING lv_ruta.

ENDFORM.                    " F_SAVE_FILE


*&---------------------------------------------------------------------*
*&      Form  F_CONVERTIR_TO_TEXTO
*&---------------------------------------------------------------------*
FORM f_convert_to_texto TABLES tb_datos tb_fields.

  DATA: cnt   TYPE i,
        my_tabix LIKE sy-tabix,
        columns TYPE i,
        my_subrc LIKE sy-subrc,
        wa_numerical TYPE c VALUE '#',
        wa_string TYPE string.

  FIELD-SYMBOLS: <f>,
                 <data_tab_wa> TYPE any,
                 <field> TYPE any,
                 <fieldname> TYPE any.

  REFRESH ts_texto.

*agregar catalogo de campos
  my_subrc = 0.

  cnt = 1.

  CLEAR wa_texto.

  LOOP AT tb_fields.

    my_tabix = sy-tabix.
    ASSIGN COMPONENT 1 OF STRUCTURE tb_fields TO <f>.
    wa_string = <f>.
*          CONCATENATE wa_texto wa_string '|' into wa_texto.
    CONCATENATE wa_texto wa_string cl_abap_char_utilities=>horizontal_tab INTO wa_texto.

  ENDLOOP.

  APPEND wa_texto TO ts_texto.

  CLEAR wa_texto.

**  agregar datos
  columns = 0.
  DO.
    ASSIGN COMPONENT sy-index OF STRUCTURE tb_datos TO <f>.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    columns = sy-index.
  ENDDO.

  LOOP AT tb_datos.

    my_tabix = sy-tabix.

    CLEAR wa_texto.

    DO columns TIMES.
      ASSIGN COMPONENT sy-index OF STRUCTURE tb_datos TO <f>.
      wa_string = <f>.
      REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline IN wa_string WITH wa_numerical.
*          CONCATENATE wa_texto wa_string '|' into wa_texto.
      CONCATENATE wa_texto wa_string cl_abap_char_utilities=>horizontal_tab  INTO wa_texto.
    ENDDO.

    APPEND wa_texto TO ts_texto.

  ENDLOOP.

ENDFORM.                    "f_convert_to_texto

*&---------------------------------------------------------------------*
*&      Form  f_exportar_datos
*&---------------------------------------------------------------------*
FORM f_export_data TABLES t_datos USING w_ruta.

  DATA ruta TYPE string.

  ruta = w_ruta .

  IF sy-batch EQ 'X'.


    DATA: e_file LIKE rlgrap-filename.

    e_file = ruta.

    OPEN DATASET  e_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT .

    FIELD-SYMBOLS <fs_datos> TYPE string.

    UNASSIGN <fs_datos>.

    LOOP AT t_datos ASSIGNING <fs_datos>.

      TRANSFER <fs_datos> TO e_file.

    ENDLOOP.

    CLOSE DATASET e_file.



  ELSE .

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
*       BIN_FILESIZE          =
        filename              = ruta
        filetype              = 'ASC'
*       APPEND                = ' '
        write_field_separator = '-'
      TABLES
        data_tab              = t_datos.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    "f_exportar_datos

*&---------------------------------------------------------------------*
*&      Form  F_SALDO_CREDITO
*&---------------------------------------------------------------------*
FORM f_saldo_credito .

  DESCRIBE TABLE gt_vdarl LINES lv_lines.

  LOOP AT gt_vdarl ASSIGNING <fs_vdarl>.

    gv_ptask = gv_ptask + 1.

    CLEAR: lv_excp_flag.

    DO.

      ADD 1 TO lv_taskname.

      CLEAR lv_excp_flag.

      CALL FUNCTION 'ZFM_LOAN_AMOUNT'
        STARTING NEW TASK lv_taskname
        DESTINATION IN GROUP DEFAULT "GROUP p_rfcgr
        PERFORMING process_callback_prog ON END OF TASK
        EXPORTING
          i_company_code        = <fs_vdarl>-bukrs
          i_ranl                = <fs_vdarl>-ranl
        EXCEPTIONS
          communication_failure = 1  MESSAGE lv_msg
          system_failure        = 2  MESSAGE lv_msg
          resource_failure      = 3 "No work processes are
          OTHERS                = 4. "Add exceptions generated by


*the called function module here.  Exceptions are returned to you and you can
* respond to them here.
      CASE sy-subrc.
        WHEN 0.
          ADD 1 TO gv_snd_task.
        WHEN 1 OR 2.
*          CLEAR: ls_result.

*          MOVE <lfs_emp>-empid TO ls_result-empid.
*          MOVE 'Not_Updated'   TO ls_result-message.
*          APPEND ls_result     TO p_gt_result.
*          CLEAR ls_result.
        WHEN 3.
          lv_excp_flag = 'X'.
          WAIT UNTIL gv_rcv_task >= gv_snd_task UP TO '1' SECONDS.
        WHEN OTHERS.
*          CLEAR ls_result.
      ENDCASE.
      IF lv_excp_flag IS INITIAL.
        EXIT.
      ENDIF.

    ENDDO.

  ENDLOOP.

*— wait till everything ends
  WAIT UNTIL gv_rcv_task >= gv_snd_task UP TO 10 SECONDS.

ENDFORM.                    " F_SALDO_CREDITO

*&---------------------------------------------------------------------*
*&      Form  process_callback_prog
*&---------------------------------------------------------------------*
FORM process_callback_prog USING gv_task.

  DATA: lv_ranl  TYPE ranl.

  gv_ptask = gv_ptask - 1.

  RECEIVE RESULTS FROM FUNCTION 'ZFM_LOAN_AMOUNT'
      IMPORTING
         e_rloam                  = w_rloam
         e_ranl                   = lv_ranl
      EXCEPTIONS
           no_update = 1
           OTHERS    = 2.

  gv_rcv_task = gv_rcv_task + 1.

  gw_contrato-briwr = w_rloam-briwr.
  gw_contrato-ranl  = lv_ranl.

  APPEND gw_contrato TO gt_contrato.

  CLEAR gw_contrato.

ENDFORM.                    " PROCESS_CALLBACK_PROG

*&---------------------------------------------------------------------*
*&      Form  F_INTERESES
*&---------------------------------------------------------------------*
FORM f_intereses USING value(pt_bsid) LIKE gt_bsid[]
              CHANGING pa_sus_acum LIKE gt_sus_acum[].

  DATA: lt_bsid    LIKE gt_bsid[],
        lt_interes TYPE STANDARD TABLE OF ty_partida,
        lw_interes TYPE ty_partida,
        lt_pagos   LIKE gt_pagos[],
        lv_180     TYPE datum,
        lv_fecha   TYPE datum,
        flag       TYPE c.

  FIELD-SYMBOLS: <fs_lt_bsid> TYPE bsid.

  lt_bsid[] = pt_bsid[].

*Calcular la fecha mas antigua
  SORT: lt_bsid BY vertn zfbdt ASCENDING,
        pt_bsid BY vertn zfbdt ASCENDING.

  DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING vertn.

  DELETE pt_bsid WHERE vbewa+1(3) <> '110'.
*--------------------------------------------------------------------*
  LOOP AT lt_bsid ASSIGNING <fs_lt_bsid>.

    CLEAR: lv_180, lv_fecha.

    lv_180 = <fs_lt_bsid>-zfbdt + 180.

    IF lv_180 >= pa_fecha.

      lv_fecha  = pa_fecha.
    ELSE.
      lv_fecha  = lv_180.

    ENDIF.

    LOOP AT pt_bsid ASSIGNING <fs_bsid> WHERE ( vertn = <fs_lt_bsid>-vertn ).

      CLEAR: gw_partida.

      IF <fs_bsid>-zfbdt <=  lv_fecha .
        <fs_bsid>-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.
      ELSE.
        <fs_bsid>-kunnr = 'INT.SUS'. "INTERESES EN SUSPENSO.
      ENDIF.

      MOVE-CORRESPONDING <fs_bsid> TO gw_partida.

      COLLECT gw_partida INTO lt_interes[].

    ENDLOOP.

  ENDLOOP.

  SELECT ranl sbewart ddispo SUM( bbwhr )
    INTO TABLE lt_pagos
    FROM vissr_vdbevi
   WHERE ranl IN so_ranl
     AND sstorno NOT IN ('1','2')
     AND sbewart IN ('8301')
     AND dbudat = pa_fecha
   GROUP BY ranl sbewart ddispo.

  IF lt_interes[] IS INITIAL."INTERESES ACUMULADOS.

    LOOP AT lt_pagos ASSIGNING <fs_pagos>.
      CLEAR: lw_interes.
      lw_interes-vertn = <fs_pagos>-ranl.
      lw_interes-kunnr = 'INT.ACU'.
      lw_interes-wrbtr = lw_interes-wrbtr + <fs_pagos>-bbwhr.
      APPEND lw_interes TO lt_interes[].
    ENDLOOP.
  ELSE.

    IF lt_pagos[] IS NOT INITIAL.

      CLEAR flag.
      SORT: lt_pagos   BY ranl,
            lt_interes BY vertn.

      LOOP AT lt_pagos ASSIGNING <fs_pagos>.

        READ TABLE lt_interes INTO lw_interes WITH KEY vertn = <fs_pagos>-ranl
                                                       kunnr = 'INT.SUS'.
        IF sy-subrc = 0.
          lw_interes-wrbtr = lw_interes-wrbtr + <fs_pagos>-bbwhr.
          flag  = 'X'.
        ENDIF.

        IF flag IS INITIAL.
          READ TABLE lt_interes INTO lw_interes WITH KEY vertn = <fs_pagos>-ranl
                                                         kunnr = 'INT.ACU'.
          IF sy-subrc = 0.
            lw_interes-wrbtr = lw_interes-wrbtr + <fs_pagos>-bbwhr.
          ENDIF.
        ENDIF.

        APPEND lw_interes TO lt_interes[].

      ENDLOOP.
    ENDIF.
  ENDIF.

  pa_sus_acum[] = lt_interes[].

ENDFORM.                    " F_INTERESES
*&---------------------------------------------------------------------*
*&      Form  f_intereses_old
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE        text
*      -->(PT_BSID)    text
*      <--PA_SUS_ACUM  text
*----------------------------------------------------------------------*
FORM f_intereses_old USING value(pt_bsid) LIKE gt_bsid[]
              CHANGING pa_sus_acum LIKE gt_sus_acum[].

  DATA: lt_bsid    LIKE gt_bsid[],
        lt_interes LIKE gt_bsid_amor[],
        lw_interes LIKE LINE OF lt_interes,
        wa_interes LIKE LINE OF lt_interes,
        lt_pagos   LIKE gt_pagos[],
        lv_180     TYPE datum,
        lv_fecha   TYPE datum. "i.

  FIELD-SYMBOLS: <fs_lt_bsid> TYPE bsid.

  lt_bsid[] = pt_bsid[].

*Calcular la fecha mas antigua
  SORT: lt_bsid BY vertn zfbdt ASCENDING,
        pt_bsid BY vertn zfbdt ASCENDING.

  DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING vertn.

*  DELETE lt_bsid WHERE zfbdt >= pa_fecha.

  DELETE pt_bsid WHERE vbewa+1(3) <> '110'.
*--------------------------------------------------------------------*
  LOOP AT lt_bsid ASSIGNING <fs_lt_bsid>.

    CLEAR: lv_180, lv_fecha.

    lv_180 = <fs_lt_bsid>-zfbdt + 180.

    IF lv_180 >= pa_fecha.

      lv_fecha  = pa_fecha.
    ELSE.
      lv_fecha  = lv_180.

    ENDIF.

    LOOP AT pt_bsid ASSIGNING <fs_bsid> WHERE ( vertn = <fs_lt_bsid>-vertn ).
      "AND ( zfbdt <=  lv_fecha ) ) .

      CLEAR: gw_partida.

      IF <fs_bsid>-zfbdt <=  lv_fecha .

        "<fs_bsid>-kunnr = 'INT.SUS'. "INTERESES EN SUSPENSO.

        <fs_bsid>-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.
      ELSE.
        <fs_bsid>-kunnr = 'INT.SUS'. "INTERESES EN SUSPENSO.

        "<fs_bsid>-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.

      ENDIF.

      MOVE-CORRESPONDING <fs_bsid> TO gw_partida.

      COLLECT gw_partida INTO lt_interes[].

    ENDLOOP.

  ENDLOOP.


*--------------------------------------------------------------------*


*  LOOP AT pt_bsid ASSIGNING <fs_bsid>.
*
*    CLEAR: gw_partida.
*
*    "lv_180 = pa_fecha - <fs_bsid>-zfbdt.
*
**    IF lv_180 >= 180.
**
**      <fs_bsid>-kunnr = 'INT.SUS'. "INTERESES EN SUSPENSO.
**
**    ELSEIF  lv_180 < 180.
**
**      <fs_bsid>-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.
**
**    ENDIF.
*
*    MOVE-CORRESPONDING <fs_bsid> TO gw_partida.
*
*    COLLECT gw_partida INTO lt_interes[].
*
*  ENDLOOP.
*
**  LOOP AT pt_bsid ASSIGNING <fs_bsid>. "lt_bsid ASSIGNING <fs_bsid>.
**
**    READ TABLE lt_interes ASSIGNING <fs_int> WITH KEY vertn = <fs_bsid>-vertn BINARY SEARCH.
**    IF ( sy-subrc = 0 AND <fs_int> IS ASSIGNED ).
**
**      lv_180 = pa_fecha - <fs_bsid>-zfbdt.
**
**      IF lv_180 > 180.
**
**        <fs_int>-kunnr = 'INT.SUS'. "INTERESES EN SUSPENSO.
**
**      ELSEIF  lv_180 < 180.
**
**        <fs_int>-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.
**
**      ENDIF.
**
**    ENDIF.
**
**  ENDLOOP.
*
  SELECT ranl sbewart ddispo SUM( bbwhr )
    INTO TABLE lt_pagos
    FROM vissr_vdbevi
   WHERE ranl IN so_ranl
     AND sstorno NOT IN ('1','2')
     AND sbewart IN ('8301')
     AND dbudat = pa_fecha
   GROUP BY ranl sbewart ddispo.


  IF lt_interes[] IS INITIAL.

    LOOP AT lt_pagos ASSIGNING <fs_pagos>.
      CLEAR: lw_interes.
      lw_interes-vertn = <fs_pagos>-ranl.
      lw_interes-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.
      lw_interes-wrbtr = lw_interes-wrbtr + <fs_pagos>-bbwhr.
      APPEND lw_interes TO lt_interes[].
    ENDLOOP.
  ELSE.
    IF lt_pagos[] IS NOT INITIAL..
      SORT: lt_pagos   BY ranl,
            lt_interes BY vertn.

      LOOP AT lt_pagos ASSIGNING <fs_pagos>.

        READ TABLE lt_interes ASSIGNING <fs_int> WITH KEY vertn = <fs_pagos>-ranl
                                                          kunnr = 'INT.SUS' BINARY SEARCH.
        IF ( sy-subrc = 0 AND <fs_int> IS ASSIGNED ).

          IF <fs_int>-kunnr = 'INT.SUS'.
            <fs_int>-vertn = <fs_pagos>-ranl.
            <fs_int>-kunnr = 'INT.SUS'. "INTERESES SUSPENSO.
            <fs_int>-wrbtr = <fs_int>-wrbtr + <fs_pagos>-bbwhr.
          ELSE.
            <fs_int>-vertn = <fs_pagos>-ranl.
            <fs_int>-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.
            <fs_int>-wrbtr = <fs_int>-wrbtr + <fs_pagos>-bbwhr .
          ENDIF.
        ELSE.
          <fs_int>-vertn = <fs_pagos>-ranl.
          <fs_int>-kunnr = 'INT.ACU'. "INTERESES ACUMULADOS.
          <fs_int>-wrbtr = <fs_int>-wrbtr + <fs_pagos>-bbwhr .

          APPEND <fs_int> TO lt_interes[].
        ENDIF.
      ENDLOOP.

*      LOOP AT lt_interes ASSIGNING <fs_int>.
*
*        READ TABLE lt_pagos ASSIGNING <fs_pagos> WITH KEY ranl = <fs_int>-vertn BINARY SEARCH.
*        IF ( sy-subrc = 0  AND <fs_pagos> IS ASSIGNED ).
*
*          <fs_int>-wrbtr = <fs_int>-wrbtr + <fs_pagos>-bbwhr.
*
*        ENDIF.
*
*      ENDLOOP.

    ENDIF.

  ENDIF.

  pa_sus_acum[] = lt_interes[].

ENDFORM.                    " F_INTERESES


**&---------------------------------------------------------------------*
**&      Form  F_CONVERT_DATA
**&---------------------------------------------------------------------*
FORM f_convert_data USING p_vzzkoko TYPE vzzkoko
                 CHANGING p_zplazo  TYPE zplazo.

*  DATA: date_from   LIKE sy-datum,
*        lv_prestlfz TYPE vvprestlfz,
*        lv_mes      TYPE vvprestlfz.
*
*
** Restlaufzeit in Jahren ermitteln und anzeigen
*  CLEAR lv_prestlfz.
*
*  CHECK NOT p_vzzkoko-delfz IS INITIAL.  " only when value
*  CHECK p_vzzkoko-delfz     GT sy-datum. " only for future
*  CHECK p_vzzkoko-delfz     GT p_vzzkoko-dblfz. " only if greater (Offer!)
*
*  IF p_vzzkoko-dblfz > sy-datum.
*    date_from = p_vzzkoko-dblfz.
*  ELSE.
*    date_from = sy-datum.
*  ENDIF.
*
*  CALL FUNCTION 'REMAINING_LIFE_DISPLAY'
*    EXPORTING
*      date_from = date_from
*      date_to   = p_vzzkoko-delfz
*      display   = ' '
*    IMPORTING
*      fb_remain = lv_prestlfz. "rmf67-prestlfz.
*
** Abbruch bei negativer Restlaufzeit, falls DELFZ<DEFSZ
** => clear prestlfz
*  IF  lv_prestlfz < 0.
*    CLEAR lv_prestlfz.
*  ENDIF.
*
*  lv_mes = lv_prestlfz * 12.
*
*  p_zplazo = ceil( lv_mes ).




ENDFORM.                    " F_CONVERT_DATA
