<?xml version="1.0" encoding="ISO-8859-15"?>
<!-- AIFE 07 10 2014 - Afficher cac:Item/cbc:Description sur 9px au lieu de 7 -->
<!--AIFE 07 10 2014 - espace apres mode de paiement -->
<!--AIFE 07 10 2014 - modif reference feuille de style -->

<!DOCTYPE xsl:stylesheet[
        <!ENTITY nbsp "&#160;">
]>
<xsl:stylesheet
        xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
        xmlns = "http://www.w3.org/1999/xhtml"
        xmlns:ff = "urn:CHORUS:FacturesFournisseur"
        xmlns:inv = "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"
        xmlns:avr = "urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2"
        xmlns:cac = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
        xmlns:cbc = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
        xmlns:cec = "urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
        xmlns:cur = "urn:un:unece:uncefact:codelist:specification:54217:2001"
        xmlns:uni = "urn:un:unece:uncefact:codelist:specification:66411:2001"
        xmlns:aife="urn:AIFE:Facture:Extension"
        version = "1.0">
        <xsl:output
                method = "html"
                indent = "yes"
                standalone = "yes"
                version = "1.0"/>
        <xsl:decimal-format
                name = "decformat"
                decimal-separator = ","
                grouping-separator = " "
                digit = "#"
                pattern-separator = ";"
                NaN = "NaN"
                minus-sign = "-"
                zero-digit = "0"/>        

        <xsl:template name = "slash-date">
                <xsl:param name = "datebrute"/>
                <xsl:value-of select = "substring($datebrute, 9, 2)"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select = "substring($datebrute, 6, 2)"/>
                <xsl:text>/</xsl:text>
                <xsl:value-of select = "substring($datebrute, 1, 4)"/>
        </xsl:template>

        <xsl:template name="tokenizeNotes">
                <!--passed template parameter -->
                <xsl:param name="list"/>
                <xsl:param name="delimiter"/>
                <xsl:choose>
                        <xsl:when test="contains($list, $delimiter)">
                                <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                        <xsl:attribute name = "style">font-size:10px</xsl:attribute>
                                        <xsl:value-of select = "substring-before($list,$delimiter)"/>
                                </xsl:element>
                                </xsl:element>
                                <xsl:call-template name="tokenizeNotes">
                                        <!-- store anything left in another variable -->
                                        <xsl:with-param name="list" select="substring-after($list,$delimiter)"/>
                                        <xsl:with-param name="delimiter" select="$delimiter"/>
                                </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:choose>
                                        <xsl:when test="$list = ''">
                                                <xsl:text/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                        <xsl:attribute name = "style">font-size:10px</xsl:attribute>
                                                        <xsl:value-of select = "$list"/>
                                                </xsl:element>
                                        </xsl:otherwise>
                                </xsl:choose>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>  

        <xsl:template name = "EnteteFacture">
                <xsl:param name = "eltPere"/>
                <xsl:variable name = "codePaiement" select = "$eltPere/cac:PaymentMeans/cbc:PaymentMeansCode"/>
                <xsl:variable name = "numCompte" select = "$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cbc:ID"/>
                <xsl:element name = "center">
                        <xsl:element name = "p">
                                <xsl:attribute name = "class">titre0</xsl:attribute>
                                <xsl:choose>
                                        <xsl:when test = "$eltPere/cbc:InvoiceTypeCode = 'FACTURE'">Facture</xsl:when>
                                        <xsl:when test = "$eltPere/cbc:InvoiceTypeCode = 383">Facture</xsl:when>
                                        <xsl:when test = "$eltPere/cbc:InvoiceTypeCode = 384">Facture</xsl:when>
                                        <xsl:when test = "$eltPere/cbc:InvoiceTypeCode = 385">Facture</xsl:when>
                                        
                                        <!--AXYUS : 25/05/2016 Report : SBO : Suppression du type acompte
                                        <xsl:when test = "$eltPere/cbc:InvoiceTypeCode = 386">Acompte</xsl:when> -->
                                        <!--AXYUS : 25/05/2016 FIN Report-->
                                        
                                        <xsl:when test = "$eltPere/cbc:InvoiceTypeCode = 'AVOIR'">Avoir</xsl:when>
                                        <xsl:otherwise>Facture</xsl:otherwise>
                                </xsl:choose>
                                &nbsp;
                                <xsl:value-of select = "$eltPere/cbc:ID"/>
                                <xsl:if test = "$eltPere/cbc:IssueDate">
                                        &nbsp;du&nbsp;
                                        <xsl:call-template name = "slash-date">
                                                <xsl:with-param name = "datebrute" select = "$eltPere/cbc:IssueDate"/>
                                        </xsl:call-template>
                                </xsl:if>
                                
                                <!--AXYUS : 25/05/2016 Report : SBO : ajout de la période de facturation-->
                                <xsl:if test="$eltPere/cac:InvoicePeriod/cbc:StartDate"> &nbsp;-&nbsp;Période de
                                        facturation du&nbsp; <xsl:call-template name="slash-date">
                                                <xsl:with-param name="datebrute"
                                                        select="$eltPere/cac:InvoicePeriod/cbc:StartDate"/>
                                        </xsl:call-template>
                                </xsl:if>
                                <xsl:if test="$eltPere/cac:InvoicePeriod/cbc:EndDate"> &nbsp;au&nbsp;
                                        <xsl:call-template name="slash-date">
                                                <xsl:with-param name="datebrute"
                                                        select="$eltPere/cac:InvoicePeriod/cbc:EndDate"/>
                                        </xsl:call-template>
                                </xsl:if>
                                <xsl:if test="$eltPere/cac:InvoicePeriod/cbc:Description"> &nbsp;-&nbsp;
                                        <xsl:value-of select="$eltPere/cac:InvoicePeriod/cbc:Description"/>
                                </xsl:if>
                                <!--AXYUS : 25/05/2016 FIN Report-->
                                
                                <!--AXYUS : 25/05/2016 Report : SBO : ajout du cadre de facturation
                                  QUESTION : est-ce pertinent pour un AVOIR ?
                                -->
                                <xsl:element name="tr">
                                        <xsl:element name="td">
                                                <xsl:value-of select="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode"/>
                                                <xsl:choose>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A1'">&nbsp;: Dépôt par
                                                                un fournisseur d'une facture</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A2'">&nbsp;: Dépôt par
                                                                un fournisseur d'une facture déjà payée</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A3'">&nbsp;: Dépôt par
                                                                un fournisseur d'un mémoire de frais de justice</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A4'">&nbsp;: Dépôt par
                                                                un fournisseur d'un projet de décompte mensuel</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A5'">&nbsp;: Dépôt par
                                                                un fournisseur d'un état d'acompte</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A6'">&nbsp;: Dépôt par
                                                                un fournisseur d'un état d'acompte validé</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A7'">&nbsp;: Dépôt par
                                                                un fournisseur d'un projet de décompte final</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A8'">&nbsp;: Dépôt par
                                                                un fournisseur d'un décompte général et définitif</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A9'">&nbsp;: Dépôt par
                                                                un sous-traitant d'une facture</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A10'">&nbsp;: Dépôt par
                                                                un sous-traitant d'un projet de décompte mensuel</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A11'">&nbsp;: Dépôt par
                                                                un sous-traitant d'un projet de décompte final</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A12'">&nbsp;: Dépôt par
                                                                un cotraitant d'une facture</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A13'">&nbsp;: Dépôt par
                                                                un cotraitant d'un projet de décompte mensuel</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A14'">&nbsp;: Dépôt par
                                                                un cotraitant d'un projet de décompte final</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A15'">&nbsp;: Dépôt par
                                                                une MOE d'un état d'acompte</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A16'">&nbsp;: Dépôt par
                                                                une MOE d'un état d'acompte validé</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A17'">&nbsp;: Dépôt par
                                                                une MOE d'un projet de décompte général</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A18'">&nbsp;: Dépôt par
                                                                une MOE d'un décompte général</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A19'">&nbsp;: Dépôt par
                                                                une MOA d'un état d'acompte validé</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A20'">&nbsp;: Dépôt par
                                                                une MOA d'un décompte général</xsl:when>
                                                        <xsl:when test="$eltPere/cec:UBLExtensions/cec:UBLExtension/cec:ExtensionContent/aife:FactureExtension/aife:CategoryCode = 'A21'">&nbsp;: Dépôt par
                                                                un bénéficiaire d'une demande de remboursement de la TIC</xsl:when>
                                                        <xsl:otherwise>???</xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:element>
                                </xsl:element>
                                <!--AXYUS : 25/05/2016 FIN Report-->
                        </xsl:element>
                </xsl:element>
                
                <xsl:element name = "table">
                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                        <xsl:element name = "tr">
                                <xsl:element name = "th">
                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                        Récapitulatif
                                </xsl:element>
                        </xsl:element>
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <xsl:attribute name = "style">padding: 15px</xsl:attribute>
                                        <xsl:element name = "table">
                                                <xsl:attribute name = "width">100%</xsl:attribute>
                                                <xsl:element name = "colgroup">
                                                        <xsl:element name = "col">
                                                                <xsl:attribute name = "width">50%</xsl:attribute>
                                                        </xsl:element>
                                                        <xsl:element name = "col">
                                                                <xsl:attribute name = "width">50%</xsl:attribute>
                                                        </xsl:element>
                                                </xsl:element>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">
                                                                <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                Total HT
                                                                <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID">
                                                                        &nbsp;(
                                                                        <xsl:value-of select = "$eltPere/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount/@currencyID"/>
                                                                        )
                                                                </xsl:if>
                                                        </xsl:element>
                                                        <xsl:element name = "td">
                                                                <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                <xsl:attribute name = "style">text-align: right;</xsl:attribute>
                                                                <xsl:call-template name = "number">
                                                                        <xsl:with-param name = "num" select = "$eltPere/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">
                                                                <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                Total
                                                                Taxes
                                                                <xsl:if test = "$eltPere/cac:TaxTotal/cbc:TaxAmount/@currencyID">
                                                                        &nbsp;(
                                                                        <xsl:value-of select = "$eltPere/cac:TaxTotal/cbc:TaxAmount/@currencyID"/>
                                                                        )
                                                                </xsl:if>
                                                        </xsl:element>
                                                        <xsl:element name = "td">
                                                                <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                <xsl:attribute name = "style">text-align: right;</xsl:attribute>
                                                                <xsl:call-template name = "number">
                                                                        <xsl:with-param name = "num" select = "$eltPere/cac:TaxTotal/cbc:TaxAmount"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                                <!--Répartition Taxes -->
                                                <xsl:if test = "$eltPere/cac:TaxTotal/cac:TaxSubtotal">
                                                        <xsl:element name = "tr">
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "colspan">2</xsl:attribute>
                                                                        <xsl:attribute name = "style">padding-left: 20px</xsl:attribute>
                                                                        <xsl:element name = "table">
                                                                                <xsl:attribute name = "class">EnteteSite</xsl:attribute>
                                                                                <xsl:element name = "tr">
                                                                                        <xsl:element name = "td">
                                                                                                <xsl:attribute name = "class">EnteteSite</xsl:attribute>
                                                                                                <xsl:element name = "b">Répartition des taxes</xsl:element>
                                                                                        </xsl:element>
                                                                                </xsl:element>
                                                                        </xsl:element>
                                                                        <xsl:element name = "table">
                                                                                <xsl:attribute name = "width">100%</xsl:attribute>
                                                                                <xsl:attribute name = "style">
                                                                                        bordered
                                                                                        collapsed
                                                                                </xsl:attribute>
                                                                                <xsl:attribute name = "cellpadding">0</xsl:attribute>
                                                                                <xsl:attribute name = "cellspacing">2</xsl:attribute>
                                                                                <!--<xsl:element name="colgroup">
                                                                                <xsl:element name="col"><xsl:attribute name="width">20%</xsl:attribute></xsl:element>
                                                                                <xsl:element name="col"><xsl:attribute name="width">20%</xsl:attribute></xsl:element>
                                                                                <xsl:element name="col"><xsl:attribute name="width">20%</xsl:attribute></xsl:element>
                                                                                <xsl:element name="col"><xsl:attribute name="width">20%</xsl:attribute></xsl:element>
                                                                                <xsl:element name="col"><xsl:attribute name="width">20%</xsl:attribute></xsl:element>
                                                                                </xsl:element>
                                                                                -->
                                                                                <xsl:element name = "thead">
                                                                                        <xsl:element name = "tr">
                                                                                                <xsl:element name = "th">
                                                                                                        <xsl:attribute name = "class">RecapSousTotaux</xsl:attribute>
                                                                                                        Type Taxe
                                                                                                </xsl:element>
                                                                                                <xsl:element name = "th">
                                                                                                        <xsl:attribute name = "class">RecapSousTotaux</xsl:attribute>
                                                                                                        Taux Taxe
                                                                                                </xsl:element>
                                                                                                <xsl:element name = "th">
                                                                                                        <xsl:attribute name = "class">RecapSousTotaux</xsl:attribute>
                                                                                                        Montant HT
                                                                                                </xsl:element>
                                                                                                <xsl:element name = "th">
                                                                                                        <xsl:attribute name = "class">RecapSousTotaux</xsl:attribute>
                                                                                                        Montant Taxe
                                                                                                </xsl:element>
                                                                                                <!--<xsl:element name="th">
                                                                                                <xsl:attribute name="class">RecapSousTotaux</xsl:attribute>
                                                                                                Montant TTC
                                                                                                </xsl:element>
                                                                                                -->
                                                                                        </xsl:element>
                                                                                </xsl:element>
                                                                                <xsl:element name = "tbody">
                                                                                        <xsl:for-each select = "$eltPere/cac:TaxTotal/cac:TaxSubtotal">
                                                                                                <xsl:element name = "tr">
                                                                                                        <xsl:element name = "td">
                                                                                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                                                                                <xsl:attribute name = "class">normal</xsl:attribute>
                                                                                                                <xsl:value-of select = "./cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode/text()"/>
                                                                                                                &nbsp;(
                                                                                                                <xsl:value-of select = "./cbc:TaxAmount/@currencyID"/>
                                                                                                                )
                                                                                                        </xsl:element>
                                                                                                        <xsl:element name = "td">
                                                                                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                                                                                <xsl:attribute name = "class">right</xsl:attribute>
                                                                                                                <xsl:call-template name = "number">
                                                                                                                        <xsl:with-param name = "num" select = "./cbc:Percent/text()"/>
                                                                                                                </xsl:call-template>
                                                                                                        </xsl:element>
                                                                                                        <xsl:element name = "td">
                                                                                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                                                                                <xsl:attribute name = "class">right</xsl:attribute>
                                                                                                                <xsl:call-template name = "number">
                                                                                                                        <xsl:with-param name = "num" select = "./cbc:TaxableAmount/text()"/>
                                                                                                                </xsl:call-template>
                                                                                                        </xsl:element>
                                                                                                        <xsl:element name = "td">
                                                                                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                                                                                <xsl:attribute name = "class">right</xsl:attribute>
                                                                                                                <xsl:call-template name = "number">
                                                                                                                        <xsl:with-param name = "num" select = "./cbc:TaxAmount/text()"/>
                                                                                                                </xsl:call-template>
                                                                                                        </xsl:element>
                                                                                                        <!--<xsl:element name="td">
                                                                                                        <xsl:attribute name="class">top</xsl:attribute>
                                                                                                        <xsl:attribute name="class">right</xsl:attribute>
                                                                                                        <xsl:call-template name="number">
                                                                                                        <xsl:with-param name="num" select="./cbc:TaxableAmount/text()+./cbc:TaxAmount/text()"/>
                                                                                                        </xsl:call-template>
                                                                                                        </xsl:element>
                                                                                                        -->
                                                                                                </xsl:element>
                                                                                        </xsl:for-each>
                                                                                </xsl:element>
                                                                        </xsl:element>
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:if>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                                </xsl:element>

                                                <!--AXYUS : 25/05/2016 Report : 12/04/2016 FCA : motif éxonération -->
                                                <xsl:if
                                                        test="$eltPere/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cac:TaxScheme/cbc:TaxTypeCode/text() = 'EXONERATION'">
                                                        <xsl:element name="tr">
                                                                <xsl:element name="td">
                                                                        <xsl:attribute name="class">Recapitulatif</xsl:attribute> Motif
                                                                        éxonération : </xsl:element>
                                                                <xsl:element name="td">
                                                                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                                                        <xsl:attribute name="style">text-align: right;</xsl:attribute>
                                                                        <xsl:value-of
                                                                                select="$eltPere/cac:TaxTotal/cac:TaxSubtotal/cac:TaxCategory/cbc:TaxExemptionReason/text()"
                                                                        />
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:if>
                                                <!--AXYUS : 25/05/2016 FIN Report-->
                                                
                                                <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount">
                                                        <xsl:element name = "tr">
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                        Total
                                                                        Remises
                                                                        <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount/@currencyID">
                                                                                &nbsp;(
                                                                                <xsl:value-of select = "$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount/@currencyID"/>
                                                                                )
                                                                        </xsl:if>
                                                                </xsl:element>
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                        <xsl:attribute name = "style">text-align: right;</xsl:attribute>
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "$eltPere/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount/text()"/>
                                                                        </xsl:call-template>
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:if>
                                                <!--détails des remises -->
                                                <xsl:if test = "$eltPere/cac:AllowanceCharge">
                                                        <xsl:element name = "tr">
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "colspan">2</xsl:attribute>
                                                                        <xsl:attribute name = "style">padding-left: 20px</xsl:attribute>
                                                                        <xsl:element name = "table">
                                                                                <xsl:attribute name = "class">EnteteSite</xsl:attribute>
                                                                                <xsl:element name = "tr">
                                                                                        <xsl:element name = "td">
                                                                                                <xsl:attribute name = "class">EnteteSite</xsl:attribute>
                                                                                                <xsl:element name = "b">Répartition des remises</xsl:element>
                                                                                        </xsl:element>
                                                                                </xsl:element>
                                                                        </xsl:element>
                                                                        <xsl:element name = "table">
                                                                                <xsl:attribute name = "width">100%</xsl:attribute>
                                                                                <xsl:attribute name = "style">
                                                                                        bordered
                                                                                        collapsed
                                                                                </xsl:attribute>
                                                                                <xsl:attribute name = "cellpadding">0</xsl:attribute>
                                                                                <xsl:attribute name = "cellspacing">2</xsl:attribute>
                                                                                <xsl:element name = "thead">
                                                                                        <xsl:element name = "tr">
                                                                                                <xsl:element name = "th">
                                                                                                        <xsl:attribute name = "class">RecapSousTotaux</xsl:attribute>
                                                                                                        Type Remise
                                                                                                </xsl:element>
                                                                                                <xsl:element name = "th">
                                                                                                        <xsl:attribute name = "class">RecapSousTotaux</xsl:attribute>
                                                                                                        Montant Remise
                                                                                                </xsl:element>
                                                                                        </xsl:element>
                                                                                </xsl:element>
                                                                                <xsl:element name = "tbody">
                                                                                        <xsl:for-each select = "$eltPere/cac:AllowanceCharge">
                                                                                                <xsl:element name = "tr">
                                                                                                        <xsl:element name = "td">
                                                                                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                                                                                <xsl:attribute name = "class">normal</xsl:attribute>
                                                                                                                <xsl:value-of select = "./cbc:AllowanceChargeReason/text()"/>
                                                                                                                &nbsp;(
                                                                                                                <xsl:value-of select = "./cbc:Amount/@currencyID"/>
                                                                                                                )
                                                                                                        </xsl:element>
                                                                                                        <xsl:element name = "td">
                                                                                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                                                                                <xsl:attribute name = "class">right</xsl:attribute>
                                                                                                                <xsl:call-template name = "number">
                                                                                                                        <xsl:with-param name = "num" select = "./cbc:Amount/text()"/>
                                                                                                                </xsl:call-template>
                                                                                                        </xsl:element>
                                                                                                </xsl:element>
                                                                                        </xsl:for-each>
                                                                                </xsl:element>
                                                                        </xsl:element>
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:if>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                                </xsl:element>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">
                                                                <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                Total TTC
                                                                <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID">
                                                                        &nbsp;(
                                                                        <xsl:value-of select = "$eltPere/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount/@currencyID"/>
                                                                        )
                                                                </xsl:if>
                                                        </xsl:element>
                                                        <xsl:element name = "td">
                                                                <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                <xsl:attribute name = "style">text-align: right;</xsl:attribute>
                                                                <xsl:call-template name = "number">
                                                                        <xsl:with-param name = "num" select = "$eltPere/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                                
                                                <!--AXYUS : 25/05/2016 Report : 12/04/2016 FCA : Ajout des rubriques : "Montant charges" -->
                                                <xsl:if
                                                        test="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount and not(string-length(/inv:Invoice/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount/text())=0)">
                                                        <xsl:element name="tr">
                                                                <xsl:element name="td">
                                                                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                                                        Montant charges <xsl:if
                                                                                test="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount/@currencyID"
                                                                                > &nbsp;(<xsl:value-of
                                                                                        select="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount/@currencyID"
                                                                                />) </xsl:if>
                                                                </xsl:element>
                                                                <xsl:element name="td">
                                                                        <xsl:attribute name="class">Recapitulatif</xsl:attribute>
                                                                        <xsl:attribute name="style">text-align: right;</xsl:attribute>
                                                                        <xsl:call-template name="number">
                                                                                <xsl:with-param name="num"
                                                                                        select="$eltPere/cac:LegalMonetaryTotal/cbc:ChargeTotalAmount"
                                                                                />
                                                                        </xsl:call-template>
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:if>                                                
                                                <!--AXYUS : 25/05/2016 FIN Report-->
                                                
                                                <!--09/10/2012 : Ajout des rubriques : "A déduire (déjà payé)" et "A payer" -->
                                                <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount and not(string-length($eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount/text())=0)">
                                                        <xsl:element name = "tr">
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                        A
                                                                        déduire (déjà payé)
                                                                        <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID">
                                                                                &nbsp;(
                                                                                <xsl:value-of select = "$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount/@currencyID"/>
                                                                                )
                                                                        </xsl:if>
                                                                </xsl:element>
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                        <xsl:attribute name = "style">text-align: right;</xsl:attribute>
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "$eltPere/cac:LegalMonetaryTotal/cbc:PrepaidAmount"/>
                                                                        </xsl:call-template>
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:if>
                                                <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount and not(string-length($eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount/text())=0)">
                                                        <xsl:element name = "tr">
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                        A
                                                                        payer
                                                                        <xsl:if test = "$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID">
                                                                                &nbsp;(
                                                                                <xsl:value-of select = "$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount/@currencyID"/>
                                                                                )
                                                                        </xsl:if>
                                                                </xsl:element>
                                                                <xsl:element name = "td">
                                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                        <xsl:attribute name = "style">text-align: right;</xsl:attribute>
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "$eltPere/cac:LegalMonetaryTotal/cbc:PayableAmount"/>
                                                                        </xsl:call-template>
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:if>
                                                <!--09/10/2012 : Fin ajout des rubriques : "A déduire (déjà payé)" et "A payer" -->
                                        </xsl:element>
                                </xsl:element>
                        </xsl:element>
                </xsl:element>
                <xsl:element name = "table">
                        <!--Commentaire Entete -->
                        <!--09/10/2012 : Déplacement de l'affichage des Notes avant le Mode de réglement -->
                        <xsl:if test = "count($eltPere/cbc:Note) > 0">
                                                                <xsl:element name = "tr">
                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                </xsl:element>
                                <xsl:for-each select = "$eltPere/cbc:Note">
                                        <xsl:element name = "tr">
                                                        <xsl:call-template name="tokenizeNotes">
                                                                <xsl:with-param name="list" select="./text()"/>
                                                                <xsl:with-param name="delimiter" select="'§'"/>
                                                        </xsl:call-template>
                                        </xsl:element>
                                </xsl:for-each>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                </xsl:element>
                        </xsl:if>

                        <!-- AIFE 2014-03-28 - Periode de prestation -->
                        <xsl:if test = "$eltPere/cac:InvoicePeriod">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "style">font-size:12px</xsl:attribute>
                                                <xsl:choose>
                                                        <xsl:when test = "$eltPere/cac:InvoicePeriod/cbc:Description/text()='Période de prestation'">
                                                                Période de prestation : du 
                                                                <xsl:call-template name = "slash-date">
                                                                        <xsl:with-param name = "datebrute" select = "$eltPere/cac:InvoicePeriod/cbc:StartDate/text()"/>
                                                                </xsl:call-template>
                                                                au 
                                                                <xsl:call-template name = "slash-date">
                                                                        <xsl:with-param name = "datebrute" select = "$eltPere/cac:InvoicePeriod/cbc:EndDate/text()"/>
                                                                </xsl:call-template>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                                Date prochaine facture :
                                                                <xsl:call-template name = "slash-date">
                                                                        <xsl:with-param name = "datebrute" select = "$eltPere/cac:InvoicePeriod/cbc:StartDate/text()"/>
                                                                </xsl:call-template>
                                                        </xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>



                        <!--Type paiement -->
                        <!--AXYUS : 25/05/2016 ANNULATION  report SBO concernant le Type de paiement : 
                                  QUESTION : est-ce pertinent d'avoir un PaymentMeansCode valorisé avec des libellés : 'prélèvement' ou 'virement' à
                                             la place des code 30, 31 et 49 ? 
                        -->
                        
                        <xsl:if test = "$codePaiement">
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <xsl:attribute name = "style">font-size:12px</xsl:attribute>
										Paiement par&nbsp;

                                        <xsl:choose>
                                                <!--09/10/2012 : Ajout du code de paiement 30 -->
                                                <!--Virement ou Prelevement -->
                                                <xsl:when test = "($codePaiement='VIREMENT') and $numCompte">
                                                        <xsl:choose>
                                                                <xsl:when test = "$eltPere/cac:PaymentMeans/cbc:PaymentChannelCode/text()='IBAN'">&nbsp;sur le compte IBAN (BIC) :</xsl:when>
                                                                <!-- AIFE 07 10 2014 <xsl:otherwise>sur le compte :</xsl:otherwise> -->
                                                                <xsl:otherwise>&nbsp;sur le compte :</xsl:otherwise>
                                                        </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise/>
                                        </xsl:choose>
                                        <xsl:if test = "$codePaiement='VIREMENT'">
                                                <xsl:choose>
                                                        <xsl:when test = "$numCompte">
                                                                <xsl:choose>
                                                                        <xsl:when test = "$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID">
                                                                                <xsl:value-of select = "$numCompte"/>
                                                                                (
                                                                                <xsl:value-of select = "$eltPere/cac:PaymentMeans/cac:PayeeFinancialAccount/cac:FinancialInstitutionBranch/cbc:ID"/>
                                                                                )
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                                <xsl:value-of select = "$numCompte"/>
                                                                        </xsl:otherwise>
                                                                </xsl:choose>
                                                        </xsl:when>
                                                        <xsl:otherwise></xsl:otherwise>
                                                </xsl:choose>
                                        </xsl:if>
                                    <xsl:if test = "($codePaiement='PRELEVEMENT') or ($codePaiement='CHEQUE') or ($codePaiement='ESPECE') or ($codePaiement='AUTRE') or ($codePaiement='REPORT')"><xsl:value-of select = "$codePaiement"/></xsl:if>
                                </xsl:element>
                        </xsl:element>
                        </xsl:if>

                        <!--Date max reglement -->
                        <!--09/10/2012 : Ajout du test de présence de la rubrique PaymentDueDate-->
                        <xsl:if test = "$eltPere/cac:PaymentMeans/cbc:PaymentDueDate">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "style">font-size:12px</xsl:attribute>
                                                <xsl:choose>
                                                        <xsl:when test = "$codePaiement='49'">
                                                                Cette somme sera prélevée à partir
                                                                du :
                                                        </xsl:when>
                                                        <xsl:otherwise>Nous vous remercions de votre règlement avant le :</xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:call-template name = "slash-date">
                                                        <xsl:with-param name = "datebrute" select = "$eltPere/cac:PaymentMeans/cbc:PaymentDueDate/text()"/>
                                                </xsl:call-template>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <xsl:element name = "tr">
                                <xsl:element name = "td">&nbsp;</xsl:element>
                        </xsl:element>
                        
                        <!--AXYUS : 25/05/2016 ANNULATION report SBO concernant les Notes car la FDS a évolué et prend  
                                    déjà en compte les deux types de Notes
                        -->
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                        <xsl:attribute name = "style">font-size:10px</xsl:attribute>
                                        <xsl:value-of select = "$eltPere/cac:PaymentMeans/cbc:InstructionNote/text()"/>
                                </xsl:element>
                        </xsl:element>
                        <xsl:if test = "$eltPere/cac:PaymentTerms/cbc:Note">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                <xsl:attribute name = "style">font-size:10px</xsl:attribute>
                                                <xsl:value-of select = "$eltPere/cac:PaymentTerms/cbc:Note/text()"/>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                </xsl:element>
        </xsl:template>
        <xsl:template name = "Entete">
                <xsl:param name = "eltPere"/>
                <xsl:element name = "br"/>
                <xsl:element name = "table">
                        <xsl:attribute name = "width">100%</xsl:attribute>
                        <xsl:attribute name = "cellpadding">0</xsl:attribute>
                        <xsl:attribute name = "cellspacing">0</xsl:attribute>
                        <xsl:element name = "colgroup">
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">48%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">4%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">48%</xsl:attribute>
                                </xsl:element>
                        </xsl:element>
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <xsl:attribute name = "class">top</xsl:attribute>
                                        <xsl:element name = "table">
                                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "th">
                                                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                                                Emetteur
                                                        </xsl:element>
                                                </xsl:element>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">
                                                                <xsl:call-template name = "EntiteJuridique">
                                                                        <xsl:with-param name="eltPere" select="$eltPere"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">
                                                                <xsl:call-template name = "EntiteCommercial">
                                                                        <xsl:with-param name="eltPere" select="$eltPere"/>
                                                                </xsl:call-template>

                                                                <!--AXYUS : 25/05/2016 report : -->
                                                                <xsl:call-template name = "InformationsContactEntiteCommercial">
                                                                        <xsl:with-param name="eltPere" select="$eltPere"/>
                                                                </xsl:call-template>
                                                                <!--AXYUS : 25/05/2016 FIN report -->
                                                                
                                                                <xsl:call-template name = "InformationsFournisseur">
                                                                        <xsl:with-param name="eltPere" select="$eltPere"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">
                                                                <xsl:call-template name = "ContactFournisseur">
                                                                        <xsl:with-param name="eltPere" select="$eltPere"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:element>
                                <xsl:element name = "td">&nbsp;</xsl:element>
                                <xsl:element name = "td">
                                        <xsl:attribute name = "class">top</xsl:attribute>
                                        <xsl:element name = "table">
                                                <xsl:attribute name = "style">width: 100%</xsl:attribute>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">
                                                                <xsl:call-template name = "EnteteClient">
                                                                        <xsl:with-param name="eltPere" select="$eltPere"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                                <xsl:element name = "tr">
                                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                                </xsl:element>
                                                
                                                <!--AXYUS : 25/05/2016 report : -->
                                                <xsl:element name="tr">
                                                        <xsl:element name="td">
                                                                <xsl:call-template name="EnteteServiceRecepteur">
                                                                        <xsl:with-param name="eltPere" select="$eltPere"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:element>
                                                <!--AXYUS : 25/05/2016 FIN report -->
                                                
                                        </xsl:element>
                                </xsl:element>
                        </xsl:element>
                </xsl:element>
        </xsl:template>
        <xsl:template name = "EntiteJuridique">
                <xsl:param name = "eltPere"/>
                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity">
                        <xsl:element name = "table">
                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                <xsl:element name = "tr">
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                                Entité&nbsp;Juridique
                                        </xsl:element>
                                </xsl:element>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:element name = "b">
                                                        <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:element>
                                <xsl:for-each select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:AddressLine">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        <xsl:value-of select = "cbc:Line"/>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:for-each>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone"/>
                                                &nbsp;
                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>
                                        </xsl:element>
                                </xsl:element>

                                                             
                        </xsl:element>
                </xsl:if>
        </xsl:template>
        <xsl:template name = "EntiteCommercial">
                <xsl:param name = "eltPere"/>
                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:Party">
                        <xsl:element name = "table">
                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                <xsl:element name = "tr">
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                                Entité&nbsp;Commerciale
                                        </xsl:element>
                                </xsl:element>
                                <xsl:for-each select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyName">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        <xsl:element name = "b">
                                                                <xsl:value-of select = "cbc:Name"/>
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:for-each>
                                <xsl:for-each select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cac:AddressLine">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        <xsl:value-of select = "."/>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:for-each>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/>
                                                &nbsp;
                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
                                        </xsl:element>
                                </xsl:element>

                        </xsl:element>
                </xsl:if>
        </xsl:template>
        
        <!--AXYUS : 25/05/2016 report : 12/04/2016 FCA -->
        <xsl:template name="InformationsContactEntiteCommercial">
                <xsl:param name = "eltPere"/>
                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact">
                        <xsl:element name="table">
                                <xsl:attribute name="class">EnteteFournisseur</xsl:attribute>
                                <xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Id">
                                        <xsl:element name="tr">
                                                <xsl:element name="td"> Code service : &nbsp;<xsl:element name="b">
                                                        <xsl:value-of
                                                                select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Id"
                                                        />
                                                </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:if>
                                <xsl:if
                                        test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name">
                                        <xsl:element name="tr">
                                                <xsl:element name="td"> Nom service : &nbsp;<xsl:element name="b">
                                                        <xsl:value-of
                                                                select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name"
                                                        />
                                                </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:if>
                        </xsl:element>
                </xsl:if>
        </xsl:template>
        <!--AXYUS : 25/05/2016 FIN report-->
        
        <xsl:template name = "InformationsFournisseur">
                <xsl:param name = "eltPere"/>
                <xsl:element name = "table">
                        <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <!--AXYUS : 25/05/2016 ANNULATION report modifications concernant le type d'identifiant : @schemeName='1' pour SIRET -->
                                        <!--AXYUS : 14/06/2016 PRISE EN COMPTE du type identifiant : @schemeName='1' pour SIRET -->
                                        <xsl:choose>
                                                <xsl:when test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='1']">SIRET :&nbsp;</xsl:when>
                                                <xsl:when test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='SIRET']">SIRET :&nbsp;</xsl:when>
                                                <xsl:when test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='RIDET']">RIDET :&nbsp;</xsl:when>
                                                <xsl:otherwise>IDENTIFIANT FOURNISSEUR :&nbsp;</xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:element name = "b">
                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID/text()"/>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:element>
			<!--AXYUS : 02/06/2016 Correction suite recette : affichage du libellé "Numéro de TVA intra-communautaire" 
		                    uniquement si le numéro est présent dans le flux
			-->         
			<xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID">
	                        <xsl:element name = "tr">
	                                <xsl:element name = "td">
	                                        Numéro de TVA intra-communautaire :&nbsp;
	                                        <xsl:element name = "b">
	                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID"/>
	                                        </xsl:element>
	                                </xsl:element>
	                        </xsl:element>
			</xsl:if>
			<!--AXYUS : 02/06/2016 Correction suite recette : affichage du libellé "Régime de TVA" 
		                    uniquement si l'information est présente dans le flux
			-->         
			<xsl:if test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text()">
	                        <xsl:element name = "tr">
	                                <xsl:element name = "td">
	                                        Régime de TVA :&nbsp;
	                                        <xsl:element name = "b">
	                                                <xsl:choose>
	                                                        <xsl:when test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text() = 'TVA_SUR_DEBIT'">TVA sur les débits</xsl:when>
	                                                        <xsl:when test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text() = 'TVA_SUR_ENCAISSEMENT'">TVA sur les encaissements</xsl:when>
	                                                        <!--AXYUS : 25/05/2016 report : 12/04/2016 FCA -->
                                                        <xsl:when test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text() = 'EXONERATION'"> TVA exonérée </xsl:when>
                                                        <xsl:when test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text() = 'SANS_TVA'"> Sans TVA </xsl:when>
	                                                        <!--AXYUS : 25/05/2016 FIN report-->
	                                                        <xsl:otherwise>
	                                                                Inconnu (code=
	                                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cac:TaxScheme/cbc:TaxTypeCode/text()"/>
	                                                                )
	                                                        </xsl:otherwise>
	                                                </xsl:choose>
	                                        </xsl:element>
	                                </xsl:element>
	                        </xsl:element>
			</xsl:if>
                        <!--RCS -->
                        <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                RCS :&nbsp;
                                                <xsl:element name = "b">
                                                        <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/text()"/>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                </xsl:element>
        </xsl:template>
        <xsl:template name = "ContactFournisseur">
                <xsl:param name = "eltPere"/>
                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact">
                        <xsl:element name = "table">
                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                <xsl:element name = "tr">
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">EnteteFournisseur</xsl:attribute>
                                                Contact
                                        </xsl:element>
                                </xsl:element>
                                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Name">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        <xsl:element name = "b">
                                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Name/text()"/>
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:if>
                                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telephone">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        Téléphone :&nbsp;
                                                        <xsl:element name = "b">
                                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telephone/text()"/>
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:if>
                                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telefax">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        Télécopie :&nbsp;
                                                        <xsl:element name = "b">
                                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:Telefax/text()"/>
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:if>
                                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:ElectronicMail">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        Messagerie :&nbsp;
                                                        <xsl:element name = "b">
                                                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:AccountingContact/cbc:ElectronicMail/text()"/>
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:if>
                                
                                <!--AXYUS : 25/05/2016 report : 12/04/2016 FCA : ajout note-->
                                <xsl:if
                                        test="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Note">
                                        <xsl:element name="tr">
                                                <xsl:element name="td">
                                                        <xsl:element name="b">
                                                                <xsl:value-of
                                                                        select="$eltPere/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Note/text()"
                                                                />
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:if>
                                <!--AXYUS : 25/05/2016 FIN report -->
                        </xsl:element>
                </xsl:if>
        </xsl:template>

        <!--AXYUS : 25/05/2016 ANNULATION report du template "InformationsEncaisseur"
                    car il n'existe plus dans cette version de FDS
        -->
        
        <xsl:template name = "EnteteClient">
                <xsl:param name = "eltPere"/>
                <xsl:element name = "table">
                        <xsl:attribute name = "class">EnteteClient</xsl:attribute>
                        <xsl:element name = "tr">
                                <xsl:element name = "th">
                                        <xsl:attribute name = "class">EnteteClient</xsl:attribute>
                                        Client
                                </xsl:element>
                        </xsl:element>
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <xsl:element name = "b">
                                                <xsl:for-each select = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name">
                                                        <xsl:value-of select = "./text()"/>
                                                        <xsl:element name = "br"/>
                                                </xsl:for-each>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:element>
                        <xsl:for-each select = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:value-of select = "."/>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:for-each>
                        
                        <!--AXYUS : 25/05/2016 report : 12/04/2016 -->
                        <xsl:element name="tr">
                                <xsl:element name="td">
                                        <xsl:value-of
                                                select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName"
                                        />
                                </xsl:element>
                        </xsl:element>
                        <!--AXYUS : 25/05/2016 FIN report-->
                        
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <xsl:value-of select = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone"/>
                                        &nbsp;
                                        <xsl:value-of select = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName"/>
                                </xsl:element>
                        </xsl:element>

                </xsl:element>
                <xsl:element name = "table">
                        <xsl:attribute name = "class">EnteteClient</xsl:attribute>

                        
                        <!--AXYUS : 25/05/2016 report : 12/04/2016
                                Suppression du Compte commercial car non présent dans le mapping (et du compte de facturation -->
                        
                        <!--        
                        <xsl:if test = "$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Compte commercial']/cbc:ID">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                Compte commercial :&nbsp;
                                                <xsl:element name = "b">
                                                        <xsl:value-of select = "$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Compte commercial']/cbc:ID"/>
                                                </xsl:element>
                                                09/10/2012 : Ajout de la rubrique IssueDate 
                                                <xsl:if test = "$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Compte commercial']/cbc:IssueDate">
                                                        &nbsp;du&nbsp;
                                                        <xsl:element name = "b">
                                                                <xsl:call-template name = "slash-date">
                                                                        <xsl:with-param name = "datebrute" select = "$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Compte commercial']/cbc:IssueDate/text()"/>
                                                                </xsl:call-template>
                                                        </xsl:element>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <xsl:if test = "$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:ID">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                Compte de facturation :
                                                <xsl:element name = "b">
                                                        <xsl:value-of select = "$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:ID"/>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        Bon de commande :
                                        <xsl:element name = "b">
                                                <xsl:value-of select = "$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Bon de commande']/cbc:ID"/>
                                        </xsl:element>
                                        <xsl:if test = "$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Bon de commande']/cbc:IssueDate/text()">
                                                &nbsp;du&nbsp;
                                                <xsl:call-template name = "slash-date">
                                                        <xsl:with-param name = "datebrute" select = "$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Bon de commande']/cbc:IssueDate/text()"/>
                                                </xsl:call-template>
                                        </xsl:if>
                                </xsl:element>
                        </xsl:element>
                        -->
                        <xsl:element name="tr">
                                <xsl:element name="td"> 
                                        <xsl:element name="b">
                                        
                                        <!--AXYUS : 25/05/2016 ANNULATION report modifications concernant le type d'identifiant : @schemeName='1' pour SIRET 
                                                    <xsl:value-of select="/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='1']"/>
                                        -->
                                        <!--AXYUS : 14/06/2016 PRISE EN COMPTE du type identifiant : @schemeName='1' pour SIRET -->
                                        <xsl:choose>
                                                <xsl:when test = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='1']">SIRET :&nbsp;</xsl:when>
                                                <xsl:when test = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='SIRET']">SIRET :&nbsp;</xsl:when>
                                                <xsl:when test = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification[cbc:ID/@schemeName='RIDET']">RIDET :&nbsp;</xsl:when>
                                                <xsl:otherwise>IDENTIFIANT CLIENT :&nbsp;</xsl:otherwise>
                                        </xsl:choose>
                                        </xsl:element>
                                       	<xsl:element name = "b">
                                         	<xsl:value-of select = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyIdentification/cbc:ID/text()"/>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:element> 
			<!--AXYUS : 14/06/2016
			     MODIFICATION : 1] Affichage systématique de la balise cbc:OrderReference/cbc:ID  
					    2] Affichage de la balise cbc:ContractDocumentReference/ID en fonction de la valeur
					       de la balise cbc:DocumentTypeCode
		        -->
                        <xsl:if test="$eltPere/cac:OrderReference/cbc:ID">
                                <xsl:element name="tr">
                                        <xsl:element name="td"> Numéro d'engagement : <xsl:element name="b">
                                                <xsl:value-of
                                                        select="$eltPere/cac:OrderReference/cbc:ID"
                                                />
                                        </xsl:element>
                                                <xsl:if
                                                        test="$eltPere/cac:OrderReference/cbc:IssueDate/text()"
                                                        > &nbsp;du&nbsp; <xsl:call-template name="slash-date">
                                                                <xsl:with-param name="datebrute"
                                                                        select="$eltPere/cac:OrderReference/cbc:IssueDate/text()"
                                                                />
                                                        </xsl:call-template>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <xsl:if test="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Marché']/cbc:ID">
                                <xsl:element name="tr">
                                        <xsl:element name="td">Marché : <xsl:element name="b">
                                                <xsl:value-of
                                                        select="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Marché']/cbc:ID"
                                                />
                                        </xsl:element>
                                                <xsl:if
                                                        test="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Marché']/cbc:IssueDate/text()"
                                                        > &nbsp;du&nbsp; <xsl:call-template name="slash-date">
                                                                <xsl:with-param name="datebrute"
                                                                        select="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Marché']/cbc:IssueDate/text()"
                                                                />
                                                        </xsl:call-template>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <xsl:if test="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Bon de commande']/cbc:ID">
                                <xsl:element name="tr">
                                        <xsl:element name="td">Engagement : <xsl:element name="b">
                                                <xsl:value-of
                                                        select="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Bon de commande']/cbc:ID"
                                                />
                                        </xsl:element>
                                                <xsl:if
                                                        test="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Bon de commande']/cbc:IssueDate/text()"
                                                        > &nbsp;du&nbsp; <xsl:call-template name="slash-date">
                                                                <xsl:with-param name="datebrute"
                                                                        select="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Bon de commande']/cbc:IssueDate/text()"
                                                                />
                                                        </xsl:call-template>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <xsl:if test="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Engagement']/cbc:ID">
                                <xsl:element name="tr">
                                        <xsl:element name="td">Engagement : <xsl:element name="b">
                                                <xsl:value-of
                                                        select="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Engagement']/cbc:ID"
                                                />
                                        </xsl:element>
                                                <xsl:if
                                                        test="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Engagement']/cbc:IssueDate/text()"
                                                        > &nbsp;du&nbsp; <xsl:call-template name="slash-date">
                                                                <xsl:with-param name="datebrute"
                                                                        select="$eltPere/cac:ContractDocumentReference[cbc:DocumentTypeCode='Engagement']/cbc:IssueDate/text()"
                                                                />
                                                        </xsl:call-template>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
			<!--
                        <xsl:if test="$eltPere/cac:OrderReference/cac:DocumentReference/cbc:DocumentTypeCode='Bon de commande'">
                                <xsl:element name="tr">
                                        <xsl:element name="td"> Numéro d'engagement : <xsl:element name="b">
                                                <xsl:value-of
                                                        select="$eltPere/cac:OrderReference[cac:DocumentReference/cbc:DocumentTypeCode='Bon de commande']/cbc:ID"
                                                />
                                        </xsl:element>
                                                <xsl:if
                                                        test="$eltPere/cac:OrderReference[cac:DocumentReference/cbc:DocumentTypeCode='Bon de commande']/cbc:IssueDate/text()"
                                                        > &nbsp;du&nbsp; <xsl:call-template name="slash-date">
                                                                <xsl:with-param name="datebrute"
                                                                        select="$eltPere/cac:OrderReference[cac:DocumentReference/cbc:DocumentTypeCode='Bon de commande']/cbc:IssueDate/text()"
                                                                />
                                                        </xsl:call-template>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <xsl:if
                                test="$eltPere/cac:OrderReference/cac:DocumentReference/cbc:DocumentTypeCode='Marché'">
                                <xsl:element name="tr">
                                        <xsl:element name="td"> Numéro de marché : <xsl:element name="b">
                                                <xsl:value-of select="$eltPere/cac:OrderReference/cbc:ID"/>
                                        </xsl:element>
                                                <xsl:if
                                                        test="$eltPere/cac:OrderReference[cac:DocumentReference/cbc:DocumentTypeCode='Marché']/cbc:IssueDate/text()"
                                                        > &nbsp;du&nbsp; <xsl:call-template name="slash-date">
                                                                <xsl:with-param name="datebrute"
                                                                        select="$eltPere/cac:OrderReference[cac:DocumentReference/cbc:DocumentTypeCode='Marché']/cbc:IssueDate/text()"
                                                                />
                                                        </xsl:call-template>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <xsl:if
                                test="$eltPere/cac:OrderReference/cac:DocumentReference/cbc:DocumentTypeCode='Engagement'">
                                <xsl:element name="tr">
                                        <xsl:element name="td"> Numéro d'engagement : <xsl:element name="b">
                                                <xsl:value-of select="$eltPere/cac:OrderReference/cbc:ID"/>
                                        </xsl:element>
                                                <xsl:if
                                                        test="$eltPere/cac:OrderReference[cac:DocumentReference/cbc:DocumentTypeCode='Engagement']/cbc:IssueDate/text()"
                                                        > &nbsp;du&nbsp; <xsl:call-template name="slash-date">
                                                                <xsl:with-param name="datebrute"
                                                                        select="$eltPere/cac:OrderReference[cac:DocumentReference/cbc:DocumentTypeCode='Engagement']/cbc:IssueDate/text()"
                                                                />
                                                        </xsl:call-template>
                                                </xsl:if>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
			-->
			<!--AXYUS : 14/06/2016 FIN MODIFICATION -->         
                        <!--AXYUS : 25/05/2016 FIN report-->         
			<!--AXYUS : 02/06/2016 Correction suite recette : affichage du libellé "Facture d'origine" 
		                    uniquement si le numéro est présent dans le flux
			-->         
                        
                        <xsl:if test = "$eltPere/cbc:InvoiceTypeCode/text() != '380' and $eltPere/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID/text()">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                Facture d'origine :&nbsp;
                                                <xsl:element name = "b">
                                                        <xsl:value-of select = "$eltPere/cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID/text()"/>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                        <!--TVA Intra récepteur si présent -->
                        <xsl:if test = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID">
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                Numéro de TVA Intra-communautaire :&nbsp;
                                                <xsl:element name = "b">
                                                        <xsl:value-of select = "$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID/text()"/>
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:if>
                </xsl:element>
        </xsl:template>

        <!--AXYUS : 25/05/2016 report : -->
        <!-- Ajouté pour correspondre à l'exemple des specs externes-->
        <xsl:template name = "EnteteServiceRecepteur">
                <xsl:param name = "eltPere"/>
        <xsl:element name="table">
                <xsl:attribute name="class">EnteteServiceRecepteur</xsl:attribute>
                <xsl:element name="tr">
                        <xsl:element name="th">
                                <xsl:attribute name="class">EnteteServiceRecepteur</xsl:attribute> Service
                                Récepteur </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                        <xsl:element name="td">
                                <xsl:element name="b">
                                        <xsl:for-each
                                                select="$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:ID">
                                                <xsl:value-of select="./text()"/>
                                                <xsl:element name="br"/>
                                        </xsl:for-each>
                                </xsl:element>
                        </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                        <xsl:element name="td">
                                <xsl:value-of
                                        select="$eltPere/cac:AccountingCustomerParty/cac:AccountingContact/cbc:Name"
                                />
                        </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                        <xsl:element name="td">
                                <xsl:value-of
                                        select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:AddressLine/cbc:Line"
                                />
                        </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                        <xsl:element name="td">
                                <xsl:value-of
                                        select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName"
                                />
                        </xsl:element>
                </xsl:element>
                <xsl:element name="tr">
                        <xsl:element name="td">
                                <xsl:value-of
                                        select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:PostalZone"
                                />&nbsp; <xsl:value-of
                                        select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:CityName"
                                />
                        </xsl:element>
                </xsl:element>
                <xsl:element name="td">
                        <xsl:value-of
                                select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cac:Country/cbc:IdentificationCode"
                        />
                </xsl:element>
                <!-- 12/04/2016 FCA : note contact-->
                <xsl:element name="td">
                        <xsl:value-of
                                select="$eltPere/cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Note/text()"
                        />
                </xsl:element>
        </xsl:element>
        </xsl:template>
        <!--AXYUS : 25/05/2016 FIN report-->       

        <xsl:template name = "EnteteSite">
                <xsl:param name = "site"/>
                <xsl:param name = "nbSite"/>
                <!--Saut de page -->
                <!--09/10/2012 : Ajout du test du nombre de site pour la génération du saut de page -->
                <xsl:if test = "$nbSite>1">
                        <xsl:element name = "div">
                                <xsl:attribute name = "style">page-break-before:always</xsl:attribute>
                        </xsl:element>
                </xsl:if>
                <xsl:element name = "br"/>
                <xsl:element name = "table">
                        <xsl:attribute name = "class">EnteteSite</xsl:attribute>
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <b>
                                                Site de livraison :&nbsp;
                                                <xsl:for-each select = "$site/cac:DeliveryLocation/cbc:Description">
                                                        <xsl:value-of select = "./text()"/>
                                                        &nbsp;
                                                </xsl:for-each>
                                        </b>
                                        &nbsp;-&nbsp;
                                        <xsl:for-each select = "$site/cac:DeliveryLocation/cac:Address/cac:AddressLine">
                                                <xsl:value-of select = "cbc:Line"/>
                                                &nbsp;
                                        </xsl:for-each>
                                        <xsl:value-of select = "$site/cac:DeliveryLocation/cac:Address/cbc:PostalZone"/>
                                        &nbsp;
                                        <xsl:value-of select = "$site/cac:DeliveryLocation/cac:Address/cbc:CityName"/>
                                        &nbsp;

                                </xsl:element>
                        </xsl:element>
                </xsl:element>
        </xsl:template>
        <xsl:template name = "EnteteSiteSansSite">
                <!--Saut de page -->
                <xsl:element name = "div">
                        <xsl:attribute name = "style">page-break-before:always</xsl:attribute>
                </xsl:element>
                <xsl:element name = "br"/>
                <xsl:element name = "table">
                        <xsl:attribute name = "class">EnteteSite</xsl:attribute>
                        <xsl:element name = "tr">
                                <xsl:element name = "td">
                                        <!--AXYUS : 25/05/2016 report : SBO -->
                                        <!-- <b>Prestations/articles sans site de livraison précisé</b> -->
                                        <b>Articles rattachés au compte client</b>
                                        <!--AXYUS : 25/05/2016 FIN report-->
                                </xsl:element>
                        </xsl:element>
                </xsl:element>
        </xsl:template>
        <xsl:template name = "LigneFacture">
                <xsl:param name = "lignes"/>
                <xsl:element name = "table">
                        <xsl:attribute name = "width">100%</xsl:attribute>
                        <xsl:attribute name = "style">
                                bordered collapsed; page-break-inside:
                                avoid;
                        </xsl:attribute>
                        <xsl:attribute name = "cellpadding">0</xsl:attribute>
                        <xsl:attribute name = "cellspacing">2</xsl:attribute>
                        <!--table width="100%" style="bordered collapsed" cellpadding="0" cellspacing="0"-->
                        <xsl:element name = "colgroup">
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">5%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">45%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">10%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">11%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">10%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">9%</xsl:attribute>
                                </xsl:element>
                                <xsl:element name = "col">
                                        <xsl:attribute name = "width">10%</xsl:attribute>
                                </xsl:element>
                        </xsl:element>
                        <xsl:element name = "thead">
                                <xsl:element name = "tr">
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">bordered</xsl:attribute>
                                                <xsl:attribute name = "style">font-size: 8px;</xsl:attribute>
                                                TVA
                                        </xsl:element>
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">bordered</xsl:attribute>
                                                Dénomination de
                                                l'article
                                        </xsl:element>
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">bordered</xsl:attribute>
                                                Quantité
                                                facturée
                                        </xsl:element>
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">bordered</xsl:attribute>
                                                Prix
                                                unitaire
                                        </xsl:element>
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">bordered</xsl:attribute>
                                                <!--AXYUS : 25/05/2016 report -->
                                                <!--Quantité
                                                unitaire -->
                                                Quantité
                                                livrée
                                                <!--AXYUS : 25/05/2016 report -->
                                        </xsl:element>
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">bordered</xsl:attribute>
                                                Total
                                                remise
                                        </xsl:element>
                                        <xsl:element name = "th">
                                                <xsl:attribute name = "class">bordered</xsl:attribute>
                                                Total HT après
                                                remise
                                        </xsl:element>
                                </xsl:element>
                        </xsl:element>
                        <xsl:element name = "tbody">
                                <xsl:for-each select = "$lignes">
                                        <xsl:element name = "tr">
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">top</xsl:attribute>
                                                        <xsl:attribute name = "style">font-size: 8px;</xsl:attribute>
                                                        <xsl:choose>
                                                                <xsl:when test = "cac:Item/cac:ClassifiedTaxCategory/cbc:Percent">
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "cac:Item/cac:ClassifiedTaxCategory/cbc:Percent"/>
                                                                        </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:otherwise>&nbsp;</xsl:otherwise>
                                                        </xsl:choose>
                                                </xsl:element>
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">top normal</xsl:attribute>
                                                        <table
                                                                cellpadding = "0"
                                                                cellspacing = "0"
                                                                border = "0">
                                                                <!--09/10/2012 : Ajout de la rubrique ID -->
                                                                <xsl:if test = "cac:Item/cbc:Name">
                                                                        <tr>
                                                                                <td>
                                                                                        <xsl:if test = "./cbc:ID">
                                                                                                <xsl:value-of select = "./cbc:ID"/>
                                                                                                -
                                                                                        </xsl:if>
                                                                                        <xsl:value-of select = "cac:Item/cbc:Name"/>
                                                                                </td>
                                                                        </tr>
                                                                </xsl:if>

                                                                <!--AXYUS : 25/05/2016 report : 12/04/2016 FAC : Ajout type et sous-type-->
                                                                <xsl:if test="cac:Item/cac:AdditionalItemProperty">
                                                                        <tr>
                                                                                <td>
                                                                                        <xsl:if
                                                                                                test="./cac:Item/cac:AdditionalItemProperty/cbc:Name">
                                                                                                <xsl:value-of
                                                                                                        select="./cac:Item/cac:AdditionalItemProperty/cbc:Name"
                                                                                                /> - </xsl:if>
                                                                                        <xsl:if
                                                                                                test="./cac:Item/cac:AdditionalItemProperty/cbc:Value">
                                                                                                <xsl:value-of
                                                                                                        select="./cac:Item/cac:AdditionalItemProperty/cbc:Value"
                                                                                                />
                                                                                        </xsl:if>
                                                                                </td>
                                                                        </tr>
                                                                </xsl:if>
                                                                <!-- 12/04/2016 FAC : Ajout site livraison -->
                                                                <xsl:if test="cac:Delivery">
                                                                        <tr>
                                                                                <td>
                                                                                        <xsl:value-of select="./cac:Delivery/cbc:ID"/>
                                                                                </td>
                                                                        </tr>
                                                                </xsl:if>
                                                                <!--AXYUS : 25/05/2016 FIN report -->
                                                                <xsl:if test = "cac:Item/cbc:Description">
                                                                        <tr>
                                                                                		<!-- MODIF AIFE 07 10 2014 -->
										<td style = "font-size: 9px;">
                                                                                        <xsl:for-each select = "cac:Item/cbc:Description">
                                                                                                <xsl:value-of select = "./text()"/>
                                                                                                &nbsp;
                                                                                        </xsl:for-each>
                                                                                </td>
                                                                        </tr>
                                                                </xsl:if>
                                                                
                                                                <!--AXYUS : 25/05/2016 report : 12/04/2016 FAC : Référence produit -->
                                                                <xsl:if test="cac:Item/cac:StandardItemIdentification">
                                                                        <tr>
                                                                                <td style="font-size: 7px;">Référence produit :&nbsp;
                                                                                        <xsl:value-of
                                                                                                select="cac:Item/cac:StandardItemIdentification/cbc:ID"
                                                                                        />
                                                                                </td>
                                                                        </tr>
                                                                </xsl:if>
                                                                <!--AXYUS : 25/05/2016 FIN report -->
                                                                
                                                                <!--09/10/2012 : Ajout de la rubrique ActualDeliveryDate -->
                                                                
                                                                        <xsl:if test = "cac:Delivery/cbc:ActualDeliveryDate">
                                                                                <tr>
                                                                                        <td>
												Date de livraison :
												<xsl:call-template name = "slash-date">
                                                                                                     <xsl:with-param name = "datebrute" select = "cac:Delivery/cbc:ActualDeliveryDate/text()"/>
												</xsl:call-template>
												<!--AIFE 01/04/2014 : Ajout de la rubrique TrackingID -->	
												<xsl:if test = "cac:Delivery/cbc:TrackingID">
													- N° bon de livraison : 
												    <xsl:value-of select = "cac:Delivery/cbc:TrackingID/text()"/>
												</xsl:if>
                                                                                        </td>																						
                                                                                </tr>
                                                                        </xsl:if>
                                                                <!--Commentaire Ligne -->
                                                                <xsl:if test = "cbc:Note">
                                                                         <xsl:call-template name="tokenizeNotes">
                                                                                <xsl:with-param name="list" select="cbc:Note/text()"/>
                                                                                <xsl:with-param name="delimiter" select="'§'"/>
                                                                        </xsl:call-template>
                                                                </xsl:if>
                                                        </table>
                                                </xsl:element>
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">top right</xsl:attribute>
                                                        <xsl:choose>
                                                                <xsl:when test = "cbc:InvoicedQuantity">
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "cbc:InvoicedQuantity"/>
                                                                        </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:when test = "cbc:CreditedQuantity">
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "cbc:InvoicedQuantity"/>
                                                                        </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:otherwise>&nbsp;</xsl:otherwise>
                                                        </xsl:choose>
                                                        <!--xsl:value-of select="cbc:InvoicedQuantity"/-->
                                                </xsl:element>
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">top right</xsl:attribute>
                                                        <xsl:choose>
                                                                <xsl:when test = "cac:Price/cbc:PriceAmount">
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "cac:Price/cbc:PriceAmount"/>
                                                                        </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:otherwise>&nbsp;</xsl:otherwise>
                                                        </xsl:choose>
                                                        <!--xsl:value-of select="cac:Price/cbc:PriceAmount"/-->
                                                </xsl:element>
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">top right</xsl:attribute>
                                                        <xsl:choose>
                                                                <xsl:when test = "cac:Price/cbc:BaseQuantity">
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "cac:Price/cbc:BaseQuantity"/>
                                                                        </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:otherwise>&nbsp;</xsl:otherwise>
                                                        </xsl:choose>
                                                        <!--xsl:value-of select="cac:Price/cbc:BaseQuantity"/-->
                                                </xsl:element>
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">top right</xsl:attribute>
                                                        <!--AXYUS : 25/05/2016 ANNULATION report : SBO 
                                                                    QUESTION : Pourquoi la gestion des remises dans l'UBL est modifiée dans CPP par rapport à CHORUS_Facture ?  
                                                                    
                                                                    Le schéma permet d'avoir plusieurs montants de type AllowanceCharge (quelque soit celui utilisé) il vaut
                                                                    mieux laisser la somme même si seul un poste de remise est utilisé dans le cadre de CPP.  
                                                        -->
                                                        <xsl:choose>
                                                                <xsl:when test = "cac:AllowanceCharge/cbc:Amount">
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "format-number(sum(cac:AllowanceCharge/cbc:Amount/text()),'######0.0000;-#######.0000')"/>
                                                                        </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:otherwise>&nbsp;</xsl:otherwise>
                                                        </xsl:choose>
                                                        <!--xsl:value-of select="cac:Price/cbc:BaseQuantity"/-->
                                                </xsl:element>
                                                <xsl:element name = "td">
                                                        <xsl:attribute name = "class">top right</xsl:attribute>
                                                        <xsl:choose>
                                                                <xsl:when test = "cbc:LineExtensionAmount">
                                                                        <xsl:call-template name = "number">
                                                                                <xsl:with-param name = "num" select = "cbc:LineExtensionAmount"/>
                                                                        </xsl:call-template>
                                                                </xsl:when>
                                                                <xsl:otherwise>&nbsp;</xsl:otherwise>
                                                        </xsl:choose>
                                                        <!--xsl:value-of select="cbc:LineExtensionAmount"/-->
                                                </xsl:element>
                                        </xsl:element>
                                </xsl:for-each>
                                <!--<xsl:if test="count(/inv:Invoice/cac:Delivery) > 1">
                                -->
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "colspan">6</xsl:attribute>
                                                &nbsp;
                                        </xsl:element>
                                </xsl:element>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "colspan">6</xsl:attribute>
                                                <xsl:attribute name = "style">font-size: 12px</xsl:attribute>
                                                <b>Totaux du site de livraison, pour information :</b>
                                        </xsl:element>
                                </xsl:element>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "colspan">6</xsl:attribute>
                                                &nbsp;
                                        </xsl:element>
                                </xsl:element>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                <xsl:attribute name = "class">gras</xsl:attribute>
                                                <xsl:attribute name = "colspan">5</xsl:attribute>
                                                Brut HT
                                        </xsl:element>
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                <xsl:attribute name = "class">right</xsl:attribute>
                                                <xsl:call-template name = "number">
                                                        <xsl:with-param name = "num" select = "format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount)+sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge/cbc:Amount),'######0.0000;-#######.0000')"/>
                                                </xsl:call-template>
                                        </xsl:element>
                                </xsl:element>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                <xsl:attribute name = "class">gras</xsl:attribute>
                                                <xsl:attribute name = "colspan">5</xsl:attribute>
                                                Remises à la ligne
                                        </xsl:element>
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                <xsl:attribute name = "class">right</xsl:attribute>
                                                <!--AXYUS : 25/05/2016 ANNULATION report : SBO 
                                                                    QUESTION : Pourquoi la gestion des remises dans l'UBL est modifiée dans CPP par rapport à CHORUS_Facture ?  
                                                 -->
                                                <xsl:call-template name = "number">
                                                        <xsl:with-param name = "num" select = "format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cac:AllowanceCharge/cbc:Amount),'######0.0000;-#######.0000')"/>
                                                </xsl:call-template>
                                        </xsl:element>
                                </xsl:element>
                                <xsl:element name = "tr">
                                        <xsl:element name = "td">&nbsp;</xsl:element>
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                <xsl:attribute name = "class">gras</xsl:attribute>
                                                <xsl:attribute name = "colspan">5</xsl:attribute>
                                                Net HT
                                        </xsl:element>
                                        <xsl:element name = "td">
                                                <xsl:attribute name = "class">top</xsl:attribute>
                                                <xsl:attribute name = "class">right</xsl:attribute>
                                                <xsl:call-template name = "number">
                                                        <xsl:with-param name = "num" select = "format-number(sum($lignes[not(cac:Item/cac:AdditionalItemProperty/cbc:Name/text() = 'TYPE_LIGNE' and (cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'REGROUPEMENT' or cac:Item/cac:AdditionalItemProperty/cbc:Value/text() = 'INFORMATION'))]/cbc:LineExtensionAmount),'######0.0000;-#######.0000')"/>
                                                </xsl:call-template>
                                        </xsl:element>
                                </xsl:element>
                        </xsl:element>
                </xsl:element>
        </xsl:template>
        <xsl:template name = "PiedSite"></xsl:template>
        <xsl:template name = "PiedClient"></xsl:template>
        <xsl:template name = "PiedFournisseur">
                <xsl:param name = "eltPere"/>
                <xsl:element name = "br"/>
                <xsl:element name = "p">
                        <xsl:attribute name = "style">font-size: 10px</xsl:attribute>
                        <xsl:element name = "center">
                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:RegistrationName"/>
                                &nbsp;-
                                <xsl:for-each select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cac:AddressLine">
                                        &nbsp;
                                        <xsl:value-of select = "cbc:Line/text()"/>
                                </xsl:for-each>
                                
                                <!--AXYUS : 25/05/2016 report : -->
                                &nbsp; <xsl:value-of select="/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:StreetName"/>
                                <!--AXYUS : 25/05/2016 FIN report -->
                                
                                
                                &nbsp;-&nbsp;
                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:PostalZone"/>
                                &nbsp;
                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:RegistrationAddress/cbc:CityName"/>

                                
                                <xsl:element name = "br"/>
                                <!--AXYUS : 25/05/2016 ANNULATION report : SBO 
                                   Même si ces informations ne sont pas présentes dans le mapping, la feuille de style ne les affiches 
                                   que si elles sont présentes dans le flux.
                                -->
                                <!--Capital social RG05 -->
                                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:CorporateRegistrationScheme/cbc:ID">
                                        Capiltal social :&nbsp;
                                        <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cac:CorporateRegistrationScheme/cbc:ID/text()"/>
                                        &nbsp;-&nbsp;
                                </xsl:if>
                                <!--RCS RG05 -->
                                <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID/text()"/>
                                <!--Num TVA Intra si présent -->
                                <xsl:if test = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID">
                                        &nbsp;-&nbsp;
                                        Numéro de TVA intra-communautaire :
                                        &nbsp;:&nbsp;
                                        <xsl:value-of select = "$eltPere/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID/text()"/>
                                </xsl:if>
                        </xsl:element>
                </xsl:element>
        </xsl:template>
        <xsl:template name = "PiedFacture"></xsl:template>
        <xsl:template name = "number">
                <xsl:param name = "num"/>
                <xsl:choose>
                        <xsl:when test = "string-length(string($num)) = 0"/>
                        <xsl:when test = "number($num) = 0">0,00</xsl:when>
                        <xsl:when test = "string(number($num)) = 'NaN'"/>
                        <!--09/10/2012 : Modification des règles de formatage des nombres -->
                        <!--22/10/2012 : Abandon de la methode test="format-number(((number($num) * 100)  - floor((number($num) * 100))),'0.0') > 0.0"
                        a la suite des problèmes d'arrondi  -->
                        <xsl:when test = "string-length(substring-after(string($num), '.')) > 2">
                                <xsl:choose>
                                        <xsl:when test = "substring(substring-after(string($num), '.'), 3, 1) != '0'">
                                                <xsl:value-of select = "format-number($num,'# ### ##0,0000;-# ### ###,0000','decformat')"/>
                                        </xsl:when>
                                        <xsl:when test = "string-length(substring-after(string($num), '.')) > 3 and substring(substring-after(string($num), '.'), 4, 1) != '0'">
                                                <xsl:value-of select = "format-number($num,'# ### ##0,0000;-# ### ###,0000','decformat')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <xsl:value-of select = "format-number($num,'# ### ##0,00;-# ### ###,00','decformat')"/>
                                        </xsl:otherwise>
                                </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:value-of select = "format-number($num,'# ### ##0,00;-# ### ###,00','decformat')"/>
                        </xsl:otherwise>
                </xsl:choose>
        </xsl:template>
        <xsl:template name = "initHtml">
                <xsl:param name = "eltPere"/>
                <html>
                        <head>
                                <xsl:choose>
                                        <xsl:when test="$eltPere/cac:InvoiceLine">
                                                <title>Facture Fournisseur</title>  
                                        </xsl:when>
                                        <xsl:otherwise>
                                                <title>Avoir Fournisseur</title>
                                        </xsl:otherwise>
                                </xsl:choose>
                                
                                <style type = "text/css" media = "print">
                                        .invoiceDiv {
                                        width: 100%;
                                        }
                                        @page portrait {
                                        size: 210mm 197mm;
                                        @bottom-center {
                                        content: "Page " counter(page);
                                        }
                                        }
                                </style>
                                <style type = "text/css" media = "screen">
                                        .invoiceDiv {
                                        width: 190mm;
                                        }
                                </style>
                                <style type = "text/css" media = "all">
                                        body, p, th, td {
                                        font-size: 10px;
                                        font-family: verdana, sans-serif;
                                        }
                                        .version {
                                        font-size: 10px;
                                        /* color:#FFFFFF; */
                                        }
                                        .titre0 {
                                        font-weight: bold;
                                        font-family: Arial, Helvetica, sans-serif;
                                        font-size: 20;
                                        }
                                        .center {
                                        text-align: center;
                                        }
                                        .top {
                                        vertical-align: top;
                                        }
                                        .gras {
                                        font-weight: bold;
                                        }
                                        .italic {
                                        font-style: italic;
                                        }
                                        .normal {
                                        font-style: normal;
                                        font-weight: normal;
                                        }
                                        .right {
                                        text-align: right;
                                        }
                                        .bordered {
                                        border-style: solid;
                                        border-width: 1px;
                                        border-color: black;
                                        padding: 5px;
                                        }
                                        .collapsed {
                                        border-collapse: collapse;
                                        border-spacing: 0px;
                                        }
                                        .titre1 {
                                        margin-top: 12px;
                                        margin-bottom: 0px;
                                        font-wieght: bold;
                                        font-size: 16;
                                        }
                                        .nosign {
                                        list-style-type: none;
                                        }
                                        table.EnteteFournisseur {
                                        margin: 0;
                                        border-style: solid;
                                        border-width: 1px;
                                        border-color: black;
                                        width: 100%;
                                        font-size: 12px;
                                        text-align: left;
                                        padding: 0;
                                        page-break-inside: avoid;
                                        }
                                        th.EnteteFournisseur {
                                        font-size: 15px;
                                        text-align: left;
                                        padding: 5px;
                                        background-color: #999999;
                                        }
                                        td.EnteteFournisseur {
                                        font-size: 25px;
                                        text-align: left;
                                        padding: 5px;
                                        }
                                        table.EnteteClient {
                                        margin: 0;
                                        border-style: solid;
                                        border-width: 1px;
                                        border-color: black;
                                        width: 100%;
                                        font-size: 14px;
                                        text-align: left;
                                        padding: 0;
                                        page-break-inside: avoid;
                                        }
                                        th.EnteteClient {
                                        font-size: 15px;
                                        text-align: left;
                                        padding: 5px;
                                        background-color: #999999;
                                        }
                                        table.EnteteServiceRecepteur{
                                        margin:0;
                                        border-style:solid;
                                        border-width:1px;
                                        border-color:black;
                                        width:100%;
                                        font-size:14px;
                                        text-align:left;
                                        padding:0;
                                        page-break-inside:avoid;
                                        }
                                        th.EnteteServiceRecepteur{
                                        font-size:15px;
                                        text-align:left;
                                        padding:5px;
                                        background-color:#999999;
                                        }
                                        table.EnteteSite {
                                        border-style: solid;
                                        border-width: 1px;
                                        border-color: black;
                                        padding: 10px;
                                        margin: 0;
                                        width: 100%;
                                        font-size: 12px;
                                        text-align: left;
                                        page-break-inside: avoid;
                                        background-color: #999999;
                                        }
                                        table.Recapitulatif {
                                        border-style: none;
                                        padding: 10px;
                                        margin: 0;
                                        width: 100%;
                                        font-size: 12px;
                                        text-align: left;
                                        background-color: #f0f0f0;
                                        page-break-inside: avoid;
                                        }
                                        th.Recapitulatif {
                                        font-size: 15px;
                                        font-weight: bold;
                                        text-align: left;
                                        padding: 5px;
                                        }
                                        td.Recapitulatif {
                                        font-size: 13px;
                                        }
                                        table.RecapSousTotaux {
                                        margin: 0;
                                        border-style: solid;
                                        border-width: 1px;
                                        border-color: black;
                                        width: 100%;
                                        font-size: 10px;
                                        text-align: left;
                                        padding: 0;
                                        page-break-inside: avoid;
                                        }
                                        th.RecapSousTotaux {
                                        font-size: 10px;
                                        text-align: center;
                                        padding: 5px;
                                        border-style: solid;
                                        border-width: 1px;
                                        border-color: black;
                                        }
                                        td.RecapSousTotaux {
                                        font-size: 10px;
                                        text-align: left;
                                        padding: 5px;
                                        }
                                </style>
                        </head>
                        <body>
								<!-- AIFE 07 10 2014 
                                <span class = "version">Facture Fournisseur -20140331-01</span> -->
                                <span class = "version">Ref FDS CPP : 20160614-01</span>

                                <xsl:for-each select = "$eltPere">
                                        <xsl:call-template name = "Entete">
                                                <xsl:with-param name="eltPere" select="$eltPere"/>
                                        </xsl:call-template>
                                        <xsl:call-template name = "EnteteFacture">
                                                <xsl:with-param name="eltPere" select="$eltPere"/>
                                        </xsl:call-template>
                                        
                                        <xsl:variable name = "nbDelivery" select = "count(cac:Delivery)"/>
                                        <xsl:if test = "$nbDelivery>1">
                                                <xsl:element name = "table">
                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                        <xsl:element name = "tr">
                                                                <xsl:element name = "th">
                                                                        <xsl:attribute name = "class">Recapitulatif</xsl:attribute>
                                                                        Détails de facturation par site de livraison
                                                                </xsl:element>
                                                        </xsl:element>
                                                </xsl:element>
                                        </xsl:if>
                                        <!--Traitement des lignes de facture associées à un site -->                                        
                                        <xsl:for-each select = "$eltPere/cac:Delivery">
                                                <xsl:call-template name = "EnteteSite">
                                                        <xsl:with-param name = "site" select = "."/>
                                                        <xsl:with-param name = "nbSite" select = "$nbDelivery"/>
                                                </xsl:call-template>
                                                <xsl:variable name = "SiteID" select = "cac:DeliveryLocation/cbc:ID"/>
						<xsl:value-of select="$SiteID"/>
                                                <xsl:variable name = "lignes" select = "$eltPere/cac:InvoiceLine[cac:Delivery/cbc:ID = $SiteID]"/>
                                                <xsl:call-template name = "LigneFacture">
                                                        <xsl:with-param name = "lignes" select = "$lignes"/>
                                                </xsl:call-template>
                                        </xsl:for-each>
                                        <!--Traitement des lignes de facture orphelines -->
                                        <xsl:if test = "$eltPere/cac:InvoiceLine[not(cac:Delivery/cbc:ID)]">
                                                <xsl:call-template name = "EnteteSiteSansSite"/>
                                                <xsl:call-template name = "LigneFacture">
                                                        <xsl:with-param name = "lignes" select = "$eltPere/cac:InvoiceLine[not(cac:Delivery/cbc:ID)]"/>
                                                </xsl:call-template>
                                        </xsl:if>
                                        <!--Traitement des lignes d'avoir -->
                                        <xsl:if test = "$eltPere/cac:CreditNoteLine">
                                                <xsl:call-template name = "EnteteSiteSansSite"/>
                                                <xsl:call-template name = "LigneFacture">
                                                        <xsl:with-param name = "lignes" select = "$eltPere/cac:CreditNoteLine"/>
                                                </xsl:call-template>
                                        </xsl:if>
                                        
                                        <xsl:call-template name = "PiedClient"/>
                                        <xsl:call-template name = "PiedFournisseur">
                                                <xsl:with-param name="eltPere" select="$eltPere"/>
                                        </xsl:call-template>
                                </xsl:for-each>
                        </body>
                </html>
        </xsl:template>
        <xsl:template match = "/">
                <xsl:if test="/inv:Invoice">
                        <xsl:call-template name="initHtml">
                                <xsl:with-param name="eltPere" select="/inv:Invoice"/>
                        </xsl:call-template>
                </xsl:if>
                <xsl:if test="/avr:CreditNote">
                        <xsl:call-template name="initHtml">
                                <xsl:with-param name="eltPere" select="/avr:CreditNote"/>
                        </xsl:call-template>
                </xsl:if>
        </xsl:template>
</xsl:stylesheet>
