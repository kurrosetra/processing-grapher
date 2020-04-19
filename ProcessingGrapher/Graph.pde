/* * * * * * * * * * * * * * * * * * * * * * *
 * GRAPH CLASS
 *
 * Code by: Simon Bluett
 * Email:   hello@chillibasket.com
 * * * * * * * * * * * * * * * * * * * * * * */

class Graph {

    int cL, cR, cT, cB;     // Content coordinates (left, right, top bottom)
    int gL, gR, gT, gB;     // Graph area coordinates

    float minX, maxX, minY, maxY; // Limits of data
    float[] lastX = {0}, lastY = {-99999999};   // Array containing previous x and y values

    int xScale, yScale;
    int xRate;
    String plotType;
    String plotName;

    // Ui variables
    int graphMark;
    //int uimult;
    int border;
    boolean redrawGraph;
    boolean gridLines;
    boolean squareGrid;
    boolean highlighted;


    /**********************************
     * Constructor
     **********************************/
    Graph(int left, int right, int top, int bottom, float minx, float maxx, float miny, float maxy, String name) {

        //uimult = 1;
        plotName = name;

        cL = gL = left;
        cR = gR = right;
        cT = gT = top;
        cB = gB = bottom;

        minX = minx;
        maxX = maxx;
        minY = miny;
        maxY = maxy;

        xScale = 40;
        yScale = 40;
        xRate = 60;

        graphMark = round(8 * uimult);
        border = round(30 * uimult);

        plotType = "linechart";
        redrawGraph = gridLines = true;
        squareGrid = false;
        highlighted = false;
    }
    

    /**********************************
     * Plot Data onto Graph
     **********************************/
    void changeSize(int newL, int newR, int newT, int newB) {
        cL = newL;
        cR = newR;
        cT = newT;
        cB = newB;

        for(int i = 0; i < lastX.length; i++) lastX[i] = 0;
        redrawGraph = true;
    }


    /**********************************
     * Change number of divisions on axis
     **********************************/
    void changeGraphDiv(int newx, int newy) {
        xScale = newx;
        yScale = newy;
        for(int i = 0; i < lastX.length; i++) lastX[i] = 0;
        drawGrid();
    }

    int getXscale() {
        return xScale;
    }

    int getYscale() {
        return yScale;
    }

    // Change rate at which x-axis data is shown
    int getXrate() {
        return xRate;
    }

    void setXrate(int newrate) {
        xRate = newrate;
    }

    void setSquareGrid(boolean value) {
        squareGrid = value;
    }

    // Change the minimum and maximum bounds of the graph
    void setMinMax(float newval, int type) {
        switch(type){
            case 0: minX = newval; break;
            case 1: maxX = newval; break;
            case 2: minY = newval; break;
            case 3: maxY = newval; break;
        }
        //for(int i = 0; i < lastX.length; i++) lastX[i] = 0;
        for(int i = 0; i < lastY.length; i++) lastY[i] = -99999999;
    }

    float getMinMax(int type) {
        switch(type){
            case 0: return minX;
            case 1: return maxX;
            case 2: return minY;
            case 3: return maxY;
            default: return 0;
        }
    }

    void resetGraph(){
        for(int i = 0; i < lastX.length; i++) lastX[i] = 0;
        for(int i = 0; i < lastY.length; i++) lastY[i] = -99999999;
    }

    int setXlabel(float xCoord, float yCoord) {
        if (xCoord < gL || xCoord > gR || yCoord < gT || yCoord > gB) return -1;
        stroke(c_sidebar);
        strokeWeight(1 * uimult);
        line(xCoord, gT, xCoord, gB);
        return round(map(xCoord, gL, gR, minX, maxX) / xRate);
    }

    void setGraphType(String type) {
        if (type == "linechart") plotType = "linechart";
        else if (type == "dotchart") plotType = "dotchart";
        else if (type == "barchart") plotType = "barchart";
    }

    String getGraphType() {
        return plotType;
    }

    void setHighlight(boolean state, boolean update) {
        highlighted = state;

        if (update) {
            // Clear the content area
            rectMode(CORNER);
            noStroke();
            fill(c_background);
            rect(cL + int(9 * uimult), cT + int(9 * uimult), textWidth(plotName) + int(2 * uimult), int(16 * uimult));

            textAlign(LEFT, TOP);
            fill(c_lightgrey);
            if (highlighted) fill(c_red);
            text(plotName, cL + int(10 * uimult), cT + int(10 * uimult));
        }
    }

    boolean onGraph(int xCoord, int yCoord) {
        if (xCoord >= gL && xCoord <= gR && yCoord >= gT && yCoord <= gB) return true;
        else return false;
    }

    float xGraphPos(int xCoord) {
        return map(xCoord, gL, gR, 0, 1);
    }

    float yGraphPos(int yCoord) {
        return map(yCoord, gT, gB, 0, 1);
    }

    /**********************************
     * Plot Data onto Graph
     **********************************/
    void plotData(float dataY, float dataX, int type) {
        // Deal with labels
        /*
        if(type == -1) {
            stroke(c_sidebar);
            strokeWeight(1 * uimult);
            line(map(lastX[0], minX, maxX, gL, gR), gT, map(lastX[0], minX, maxX, gL, gR), gB);
            return;
        }*/

        float xStep = 1 / float(xRate);
        int x1, y1, x2 = gL, y2;

        // Ensure that the element actually exists in data arrays
        while(lastY.length < type + 1) lastY = append(lastY, -99999999);
        while(lastX.length < type + 1) lastX = append(lastX, 0);
        
        // Redraw grid, if required
        if(lastX[type] == 0 && redrawGraph) drawGrid();

        // Bound the Y-axis data
        if (dataY > maxY && dataY != 99999999 && dataY != -99999999) dataY = maxY;
        if (dataY < minY && dataY != 99999999 && dataY != -99999999) dataY = minY;

        // Bound the X-axis
        if (dataX > maxX && dataX != 99999999 && dataX != -99999999) dataX = maxX;
        if (dataX < minX && dataX != 99999999 && dataX != -99999999) dataX = minX;

        // Only plot data if it is within bounds
        if(dataY >= minY && dataY <= maxY && dataY != 99999999) {

            // Get relevant color from list
            fill(c_colorlist[type - (c_colorlist.length * floor(type / c_colorlist.length))]);
            stroke(c_colorlist[type - (c_colorlist.length * floor(type / c_colorlist.length))]);
            strokeWeight(1 * uimult);
            
            switch(plotType){

                case "dotchart":
                    // Determine x and y coordinates
                    if(dataX == -99999999) x2 = round(map(lastX[type] + xStep, minX, maxX, gL, gR));
                    else x2 = round(map(dataX, minX, maxX, gL, gR));
                    y2 = round(map(dataY, minY, maxY, gB, gT));
                    
                    ellipse(x2, y2, 2*uimult, 2*uimult);
                    break;

                case "barchart":
                    // Determine x and y coordinates
                    x1 = round(map(lastX[type], minX, maxX, gL, gR));
                    if(dataX == -99999999) x2 = round(map(lastX[type] + xStep, minX, maxX, gL, gR));
                    else x2 = round(map(dataX, minX, maxX, gL, gR));
                    y1 = round(map(dataY, minY, maxY, gB, gT));
                    if (minY <= 0) y2 = round(map(0, minY, maxY, gB, gT));
                    else y2 = round(map(minY, minY, maxY, gB, gT));
                    
                    rectMode(CORNERS);
                    rect(x1, y1, x2, y2);
                    break;

                // linechart
                default: 
                    // Only draw line if last value is set
                    if(lastY[type] != 99999999){
                        // Determine x and y coordinates
                        x1 = round(map(lastX[type], minX, maxX, gL, gR));
                        if(dataX == -99999999) x2 = round(map(lastX[type] + xStep, minX, maxX, gL, gR));
                        else x2 = round(map(dataX, minX, maxX, gL, gR));
                        y1 = round(map(lastY[type], minY, maxY, gB, gT));
                        y2 = round(map(dataY, minY, maxY, gB, gT));
                        line(x1, y1, x2, y2);
                    }
                    break;
            }
        }

        if(int(lastY[type]) != -99999999) { 
            if(dataX == -99999999) lastX[type] = lastX[type] + xStep;
            else lastX[type] = dataX;
        } else lastX[type] = 0;
        lastY[type] = dataY;

        if(x2 > gR) {
            if (type == lastX.length - 1) {
              for(int i = 0; i < lastX.length; i++) lastX[i] = 0;
            } else lastX[type] = 0;
            redrawGraph = true;
        }
    }


    /**********************************
     * Plot a Rectangle on the Graph
     **********************************/
    void plotRectangle(float dataY1, float dataY2, float dataX1, float dataX2, int type) {

        // Only plot data if it is within bounds
        if (dataY1 >= minY && dataY1 <= maxY && dataY2 >= minY && dataY2 <= maxY) {
            if (dataX1 >= minX && dataX1 <= maxX && dataX2 >= minX && dataX2 <= maxX) {

                // Get relevant color from list
                fill(c_colorlist[type - (c_colorlist.length * floor(type / c_colorlist.length))]);
                stroke(c_colorlist[type - (c_colorlist.length * floor(type / c_colorlist.length))]);
                strokeWeight(1 * uimult);

                // Determine x and y coordinates
                int x1 = round(map(dataX1, minX, maxX, gL, gR));
                int x2 = round(map(dataX2, minX, maxX, gL, gR));
                int y1 = round(map(dataY1, minY, maxY, gB, gT));
                int y2 = round(map(dataY2, minY, maxY, gB, gT));
                
                rectMode(CORNERS);
                rect(x1, y1, x2, y2);
            }
        }
    }


    /**********************************
     * Draw Grid
     **********************************/
    void drawGrid() {
        redrawGraph = false;

        // X and Y axis zero
        float yZero = 0, xZero = 0;
        if ((minY > 0) || (maxY < 0)) yZero = minY;

        int yOffset = round(map(yZero, minY, maxY, 0, yScale));
        int xOffset = round(map(xZero, minX, maxX, 0, xScale));

        float yDivUnit = abs((maxY - yZero) / float(yScale - yOffset));
        float xDivUnit = abs((maxX - minX) / float(xScale));

        // Text width and height
        int padding = int(4 * uimult);
        int yTextWidth = 0;
        int xTextWidth = 0;
        int yTextHeight = round(12 * uimult) + padding;
        int xTextHeight = round(12 * uimult) + padding;

        textSize(12 * uimult);
        textFont(base_font);

        // Find largest width, and use that as our width value
        for (int i = 1; i < yScale; i++) {
            if (textWidth(nfs(round(i * yDivUnit * 100) / 100.0,0,0)) + padding > yTextWidth) yTextWidth = round(textWidth(nfs(round(i * yDivUnit * 100) / 100.0,0,0)) + padding);
        }
        for (int i = 1; i < xScale; i++) {
            if (textWidth(nfs(round(i * xDivUnit * 100) / 100.0,0,0)) + padding > xTextWidth) xTextWidth = round(textWidth(nfs(round(i * xDivUnit * 100) / 100.0,0,0)) + padding);
        }

        // Calculate graph area bounds
        gL = cL + border + yTextWidth + graphMark + int(2 * uimult);
        gT = cT + border;
        gR = cR - border;
        gB = cB - border - xTextHeight - graphMark;

        if (squareGrid) {
            if (gR - gL > gB - gT) gR -= ((gR - gL) - (gB - gT));
            else gB -= ((gB - gT) - (gR - gL));
        }

        // Clear the content area
        rectMode(CORNER);
        noStroke();
        fill(c_background);
        rect(cL, cT, cR - cL, cB - cT);

        // Setup drawing parameters
        strokeWeight(1 * uimult);
        fill(c_lightgrey);
        textAlign(RIGHT, CENTER);
        textFont(base_font);

        // Add border and graph title
        stroke(c_darkgrey);
        if (cT > round((tabHeight + 1) * uimult)) line(cL, cT, cR, cT);
        if (cL > 1) line(cL, cT, cL, cB);
        line(cL, cB, cR, cB);
        line(cR, cT, cR, cB);
        stroke(c_lightgrey);

        textAlign(LEFT, TOP);
        if (highlighted) fill(c_red);
        text(plotName, cL + int(10 * uimult), cT + int(10 * uimult));
        fill(c_lightgrey);

        textAlign(RIGHT, CENTER);

        // ---------- Y-AXIS ----------
        int labelsHeight = yScale * yTextHeight;

        // Draw each of the division markings
        for (int i = 0;  i < yScale; i++){

            float currentY = yZero;
            if (i < yOffset) currentY -= yDivUnit * (yOffset - i);
            else currentY += yDivUnit * (i - yOffset);

            float currentYpixel = map(currentY, minY, maxY, gB, gT);

            if (currentYpixel >= gT && currentYpixel <= gB) {
                // Small inbetween mark
                stroke(c_lightgrey);
                line(gL - (graphMark * 0.6), currentYpixel, gL - round(1 * uimult), currentYpixel);

                if (squareGrid && gridLines) {
                    stroke(c_darkgrey);
                    line(gL, currentYpixel, gR, currentYpixel);
                }

                // Only show labels if there is enough room on screen
                for (float j = 1; j <= yScale; j*=2){
                    
                  
                    if ((i%j == 0) && (labelsHeight / j < gB - gT)) {

                        // Draw background grid line, if enabelled
                        if (gridLines) {
                            stroke(c_darkgrey);
                            line(gL, currentYpixel, gR, currentYpixel);
                        }

                        // Limit to 2 decimal places, but only show decimals if needed
                        String label = nf(int(currentY * 100) / 100.0,0,0);

                        // Draw axis labelling
                        stroke(c_lightgrey);
                        text(label, cL + border, currentYpixel - ((yTextHeight + padding) / 2), yTextWidth, yTextHeight);
                        line(gL - graphMark, currentYpixel, gL - round(1 * uimult), currentYpixel);
                        break;
                    }
                }
            }
        }


        // ---------- X-AXIS ----------
        textAlign(CENTER, CENTER);
        textFont(base_font);
        int labelsWidth = xScale * xTextWidth;

        // Draw each of the division markings
        for (int i = 0;  i < xScale; i++){

            float currentX = xZero;
            if (i < xOffset) currentX -= xDivUnit * (xOffset - i);
            else currentX += xDivUnit * (i - xOffset);

            float currentXpixel = map(currentX, minX, maxX, gL, gR);
            float yZeroPixel = map(yZero, minY, maxY, gB, gT);

            // Small inbetween mark
            stroke(c_lightgrey);
            line(currentXpixel, gB, currentXpixel, gB + (graphMark * 0.6));

            if (squareGrid && gridLines) {
                stroke(c_darkgrey);
                line(currentXpixel, gT, currentXpixel, gB);
            }

            // Only show labels if there is enough room on screen
            for (int j = 1; j <= xScale; j*=2){

                if ((i%j == 0) && (labelsWidth / j < gR - gL)) {

                    // Draw background grid line, if enabelled
                    if (gridLines) {
                        stroke(c_darkgrey);
                        line(currentXpixel, gT, currentXpixel, gB);
                    }

                    // Limit to 2 decimal places, but only show decimals if needed
                    String label = nf(round(currentX * 100) / 100.0,0,0);

                    // Draw axis labelling
                    stroke(c_lightgrey);
                    text(label, currentXpixel - (xTextWidth / 2), gB + graphMark, xTextWidth, xTextHeight);
                    line(currentXpixel, gB, currentXpixel, gB + graphMark);
                    break;
                }
            }
        }

        stroke(c_lightgrey);
        line(gL, gT, gL, gB);

        stroke(c_lightgrey);
        line(gL, map(yZero, minY, maxY, gB, gT), gR, map(yZero, minY, maxY, gB, gT));
    }
}
