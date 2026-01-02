import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalaryChart extends StatelessWidget {
  final List<dynamic> payrolls;

  const SalaryChart({super.key, required this.payrolls});

  @override
  Widget build(BuildContext context) {
    // 1. PREPARACIÓN DE DATOS
    // Necesitamos ordenar las nóminas por fecha (de la más antigua a la más nueva)
    // para que la línea vaya de izquierda a derecha correctamente.
    List<dynamic> sortedPayrolls = List.from(payrolls);
    sortedPayrolls.sort((a, b) {
      String dateA = a['upload_date'] ?? "";
      String dateB = b['upload_date'] ?? "";
      return dateA.compareTo(dateB);
    });

    // Si hay pocos datos, mostramos un mensaje en vez del gráfico
    if (sortedPayrolls.length < 2) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "Sube al menos 2 nóminas\npara ver tu evolución.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400),
        ),
      );
    }

    // Convertimos los datos a puntos (X, Y)
    // X = Índice (0, 1, 2...)
    // Y = Salario Neto
    List<FlSpot> spots = [];
    double maxSalario = 0;
    double minSalario = 999999;

    for (int i = 0; i < sortedPayrolls.length; i++) {
      double neto = (sortedPayrolls[i]['salario_neto'] ?? 0.0).toDouble();
      spots.add(FlSpot(i.toDouble(), neto));
      
      if (neto > maxSalario) maxSalario = neto;
      if (neto < minSalario) minSalario = neto;
    }

    // Márgenes para que la gráfica no toque los bordes arriba/abajo
    double minY = minSalario * 0.9; 
    double maxY = maxSalario * 1.1;

    // Colores
    final Color lineColor = Theme.of(context).colorScheme.primary;
    
    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 25, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 20),
            child: Text(
              "Evolución Salarial",
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.grey.shade700
              ),
            ),
          ),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false), // Sin cuadrícula de fondo
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Sin números a la izq
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Podríamos poner fechas aquí
                ),
                borderData: FlBorderData(show: false), // Sin borde cuadrado
                minX: 0,
                maxX: (sortedPayrolls.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true, // Línea curva suave
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true), // Muestra puntitos en cada nómina
                    belowBarData: BarAreaData(
                      show: true,
                      color: lineColor.withOpacity(0.1), // Relleno suave debajo
                    ),
                  ),
                ],
                // Tooltip al tocar un punto
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.blueGrey.shade800,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          "${barSpot.y.toStringAsFixed(0)} €",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
