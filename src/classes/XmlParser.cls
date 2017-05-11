public with sharing class XmlParser {
    private final String PAYMENTHISTORY = 'paymentHistory';

    public Map<Integer, List<PaymentHistoryWrapper>> getXmlFromAttachmnet(Id applicationId){

        List<Attachment> attachment = [
                                SELECT Id, Body, Name
                                FROM Attachment
                                WHERE ParentId =: 'a000Y00000B1Exx'
                                    AND Name like 'Raw_Response%'
                                ORDER BY CreatedDate
                                LIMIT 1];

        if (attachment.isEmpty()) {
            System.debug('::DEBUG:: Record do not have appropriate attachment');
            return null;
        }

        String attachmentString = attachment[0].Body.toString();
        Dom.Document doc = new Dom.Document();
        doc.load(attachmentString);

        Dom.XMLNode root = doc.getRootElement();
        Dom.XMLNode body = root.getChildElements()[1];
        Dom.XMLNode creditSearchResponse = body.getChildElements()[0];
        Dom.XMLNode soleSearch = creditSearchResponse.getChildElements()[2];
        Dom.XMLNode primary = soleSearch.getChildElements()[0];
        Dom.XMLNode suppliedAddressData = primary.getChildElements()[0];
        Dom.XMLNode addressSpecificData = suppliedAddressData.getChildElements()[1];
        Dom.XMLNode insightData = addressSpecificData.getChildElements()[1];

        List<Dom.XMLNode> debtAnalyses = insightData.getChildElements();

        Integer counter = 1;
        Map<Integer, List<PaymentHistoryWrapper>> debtAnalysesWithPaymentHistories = new Map<Integer, List<PaymentHistoryWrapper>>();

        for (Dom.XmlNode debtAnalys: debtAnalyses){
            List<Dom.XMLNode> paymentHistoriesXMLNodes = debtAnalys.getChildElements();
            System.debug(debtAnalys.getName());

            for (Dom.XmlNode debtAnalysXmlNode : paymentHistoriesXMLNodes) {
                if (debtAnalysXmlNode.getName().equals(PAYMENTHISTORY)) {
                    PaymentHistoryWrapper paymentHistoryWrapper =
                            new PaymentHistoryWrapper(debtAnalysXmlNode.getChildElements()[0].getText(), debtAnalysXmlNode.getChildElements()[1].getText());

                    if (debtAnalysesWithPaymentHistories.get(counter) != null) {
                        debtAnalysesWithPaymentHistories.get(counter).add(paymentHistoryWrapper);
                    } else {
                        List<PaymentHistoryWrapper> paymentHistoriesWrappers = new List<PaymentHistoryWrapper>();
                        paymentHistoriesWrappers.add(paymentHistoryWrapper);
                        debtAnalysesWithPaymentHistories.put(counter, paymentHistoriesWrappers);
                    }
                }
            }
            counter++;
        }

        Dom.XMLNode linkedAddressData = primary.getChildElements()[1];
        Dom.XMLNode addressSpecificDataLinked = linkedAddressData.getChildElements()[1];
        Dom.XMLNode insightDataLinked = addressSpecificDataLinked.getChildElements()[2];

        List<Dom.XMLNode> debtAnalysesLinked = insightDataLinked.getChildElements();

        for (Dom.XmlNode debtAnalys: debtAnalysesLinked){
            List<Dom.XMLNode> paymentHistoriesXMLNodes = debtAnalys.getChildElements();

            for (Dom.XmlNode debtAnalysXmlNode : paymentHistoriesXMLNodes) {
                if (debtAnalysXmlNode.getName().equals(PAYMENTHISTORY)) {
                    PaymentHistoryWrapper paymentHistoryWrapper =
                            new PaymentHistoryWrapper(debtAnalysXmlNode.getChildElements()[0].getText(), debtAnalysXmlNode.getChildElements()[1].getText());

                    if (debtAnalysesWithPaymentHistories.get(counter) != null) {
                        debtAnalysesWithPaymentHistories.get(counter).add(paymentHistoryWrapper);
                    } else {
                        List<PaymentHistoryWrapper> paymentHistoriesWrappers = new List<PaymentHistoryWrapper>();
                        paymentHistoriesWrappers.add(paymentHistoryWrapper);
                        debtAnalysesWithPaymentHistories.put(counter, paymentHistoriesWrappers);
                    }
                }
            }
            counter++;
        }

        for (Integer key : debtAnalysesWithPaymentHistories.keySet()) {
            System.debug(key + ':' + debtAnalysesWithPaymentHistories.get(key));
        }

        return debtAnalysesWithPaymentHistories;
    }

    class PaymentHistoryWrapper{
        public String ageInMonths{get;set;}
        public String paymentStatus{get;set;}

        public PaymentHistoryWrapper(String ageInMonths, String paymentStatus){
            this.ageInMonths = ageInMonths;
            this.paymentStatus = paymentStatus;
        }
    }
}