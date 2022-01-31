package com.wolper.services;



import com.lowagie.text.*;
import com.lowagie.text.html.WebColors;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.wolper.domain.JournalEntity;
import com.wolper.domain.UsersEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.view.AbstractView;
import org.springframework.web.servlet.view.document.AbstractPdfView;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.text.Collator;
import java.util.*;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListMap;
import java.util.function.BiConsumer;
import java.util.function.BinaryOperator;
import java.util.function.Function;
import java.util.function.Supplier;
import java.util.stream.Collector;
import java.util.stream.Collectors;
import java.util.stream.IntStream;


@Configuration
public class PdfReportView {

    @Bean(name = "pdfYearReportView")
    public AbstractView pdfYearReportView() {


        return new AbstractPdfView() {

            @Autowired
            GetUserInfoService getUserInfoService;

            @Override
            protected Document newDocument() {
                Document document = new Document(PageSize.A4.rotate());
                document.setMargins(15, 15, 30, 30);
                return document;
            }

            @Override
            protected void buildPdfDocument(Map model, Document document,
                                            PdfWriter writer, HttpServletRequest request,
                                            HttpServletResponse response) throws DocumentException {

                //get font
                ServletContext context = request.getSession().getServletContext();
                String fullPath = context.getRealPath("/WEB-INF/private/fonts/arial.ttf");
                FontFactory.register(fullPath, "ARIAL");


                //get data to render
                Map<String, String> pdfData = (Map<String, String>) model.get("pdfData");
                String form = pdfData.get("form");
                String subj = pdfData.get("subj");
                String server_context = pdfData.get("context");


                //string to navigate to enter mark page
                String goToEdit = "";
                if (form != null && subj != null && server_context != null)
                    goToEdit = linkStingURL(server_context, subj, form);


                //check if there is somsing to render
                if (form == null || subj == null) {
                    document.add(showErrorPDF());
                    return;
                }
                if (form.isEmpty() || subj.isEmpty()) {
                    document.add(showErrorPDF());
                    return;
                }
                List<JournalEntity> journal = getUserInfoService.getReportData(subj, form);
                if (journal.isEmpty()) {
                    document.add(showErrorPDF());
                    return;
                }


                //start prepare header
                Locale locale = new Locale.Builder().setLanguage("uk").setRegion("UA").build();
                Set<String> nameSet = journal.stream()
                        .map(JournalEntity::getStudent).map(UsersEntity::getFirstName)
                        .collect(Collectors.toCollection(() -> new TreeSet<String>(Collator.getInstance(locale))));
                int rowCount = nameSet.size();
                float[] formatArray = new float[rowCount + 2];
                IntStream.rangeClosed(1, rowCount).forEach(i -> formatArray[i] = 1.7f);
                formatArray[0] = 5f;
                formatArray[rowCount + 1] = 8f;




                //create table with header and footer
                PdfPTable table = new PdfPTable(formatArray);
                for (int c = 1; c <= 2; c++) {
                    table.addCell(addSell("Дата", false,false, null));
                    nameSet.stream().forEach(cell -> table.addCell(addSell(cell, false,true, null)));
                    table.addCell(addSell("Робота", false,false, null));
                }
                table.setHeaderRows(2);
                table.setFooterRows(1);




                //prepare body in stream Java 8 way
                //dateSortedRows is a table of rows - derived from stream grouped by date
                Map<Calendar, Map<String, String>> dateSortedRows = journal.parallelStream()
                        .collect(Collectors.groupingByConcurrent(JournalEntity::getDate, new JournalCollector()));



                int tableSize=table.size();

                //render body
                Set<Calendar> dateSet = new TreeSet(Collections.reverseOrder());
                dateSet.addAll(dateSortedRows.keySet());
                for (Calendar curDate : dateSet) {
                    Map<String, String> curNameMarkMap = dateSortedRows.get(curDate);
                    if (curNameMarkMap == null) continue;
                    //escape empty strings
                    if (curNameMarkMap.get("empty").equals("yes")) continue;
                    //highlight topic marked lines
                    boolean blackHighlight = curNameMarkMap.get("work").equals("Тематична")? true:false;
                    //start row with date
                    table.addCell(addSell(formatDate(curDate), blackHighlight, false, goToEdit));
                    //parse row
                    for (String curName : nameSet) {
                        curNameMarkMap = dateSortedRows.get(curDate);
                        String curMark = null;
                        curMark = curNameMarkMap.get(curName);
                        if (curMark != null) table.addCell(addSell(curMark,  blackHighlight,false, null));
                        else table.addCell(addSell(" ", blackHighlight, false,null));
                    }
                    //finish row with work
                    table.addCell(addSell(curNameMarkMap.get("work"), blackHighlight,false, null));
                }


                //check if we have anything to render
                if (table.size()==tableSize) {
                    document.add(showErrorPDF());
                    return;
                }

                //complete the document
                document.add(table);
            }




            //format cell
            protected PdfPCell addSell(String s, boolean black, boolean vertical, String goToEdit) {

                PdfPCell cell = new PdfPCell();
                cell.setPadding(2);
                if (vertical) cell.setRotation(90);
                Chunk chunk = new Chunk(s, FontFactory.getFont("ARIAL", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, 6f));

                //in case of date - adding navigating to edit page
                try {
                    if (!s.equals("Підсумки"))
                        if (goToEdit != null)
                            chunk.setAnchor(goToEdit + URLEncoder.encode(s, "UTF-8"));
                } catch (UnsupportedEncodingException e) {logger.info("Помилка перетворення дати в квері строку! " + s);}

                //adding color for summury cells
                if (black) {
                    cell.setBackgroundColor(WebColors.getRGBColor("#eee"));
                }

                cell.addElement(chunk);
                return cell;
            }


            //format date
            protected String formatDate(Calendar curDate) {

                if (curDate == null) return "";
                String result = curDate.get(Calendar.DAY_OF_MONTH) + "-" + (curDate.get(Calendar.MONTH) + 1) + "-" + curDate.get(Calendar.YEAR);
                return stringForSummuryRows(result);
            }


            //build URL string to navigate to enter page
            protected String linkStingURL(String server_context, String subj, String form) {

                String result = "";
                try {
                    result = server_context +
                            "/enter#?subj=" + URLEncoder.encode(subj, "UTF-8")
                            + "&class=" + URLEncoder.encode(form, "UTF-8")
                            + "&date=";
                } catch (UnsupportedEncodingException e) {
                    logger.info("Помилка перетворення в URL!" + server_context + subj + form);
                } finally {
                    return result;
                }
            }


            protected String stringForSummuryRows(String data) {

                if ((data.indexOf("26-8") >= 0) ||
                        (data.indexOf("27-8") >= 0) ||
                        (data.indexOf("28-8") >= 0) ||
                        (data.indexOf("29-8") >= 0) ||
                        (data.indexOf("30-8") >= 0) ||
                        (data.indexOf("31-8") >= 0)) return "Підсумки";
                return data;
            }

            //error result
            protected Paragraph showErrorPDF() {

                Paragraph paragraph = new Paragraph();
                paragraph.setAlignment(Element.ALIGN_CENTER);
                paragraph.setFont(FontFactory.getFont("ARIAL", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, 25f));
                paragraph.add(new Chunk("Немає даних!"));
                return paragraph;
            }

        };

    }





    //collect Journal entries into Map<String, String>
    //Map<String, String> is a row for for each date, which contains pairs - student name and mark,
    //as well as some markers for a row, such as 'work', 'topic', 'empty row'
    class JournalCollector implements Collector<JournalEntity, Map<String, String>, Map<String, String>> {

        //get empty row
        @Override
        public Supplier<Map<String, String>> supplier() {
            return () -> {
                Map<String, String> rowForOneDate = new ConcurrentHashMap(40, 0.85f, 4);
                rowForOneDate.put("work", "");
                rowForOneDate.put("topic", "");
                rowForOneDate.put("empty", "yes");
                return rowForOneDate;
            };
        }

        //fill the row
        @Override
        public BiConsumer<Map<String, String>, JournalEntity> accumulator() {
            return (row, je) -> {
                String work = je.getWork();
                String topic = je.getTopic();
                String mark = je.getMark() == 0 ? "" : "" + je.getMark();
                if (!je.isPresent()) mark = "H";
                row.put(je.getStudent().getFirstName(), mark);
                //mark empty strings
                if (!mark.isEmpty()) row.put("empty", "no");
                if (work != null && !work.isEmpty()) row.put("work", work);
                if (topic != null && !topic.isEmpty()) row.put("topic", topic);
            };
        }

        //assemble rows
        @Override
        public BinaryOperator<Map<String, String>> combiner() {
            return (row1, row2) -> {
                row1.putAll(row2);
                return row1;
            };
        }

        //nothing
        @Override
        public Function<Map<String, String>, Map<String, String>> finisher() {
            return Function.identity();
        }


        @Override
        public Set<Characteristics> characteristics() {
            return EnumSet.of(Characteristics.IDENTITY_FINISH, Characteristics.CONCURRENT, Characteristics.UNORDERED);
        }
    }

}



//   in previous version of the programm
//   to prepare body in Java 7 way:
//
//   for (JournalEntity je : journal) {
//       Map<String, String> rowForOneDate = dateSortedRows.get(je.getDate());
//       if (rowForOneDate==null) {
//           rowForOneDate=getEmptyRow();
//           dateSortedRows.put(je.getDate(), rowForOneDate);
//       }
//       fillTheRow(rowForOneDate, je);
//   }



