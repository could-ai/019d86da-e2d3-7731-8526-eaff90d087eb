class HRCalculations {
  // Tabela INSS 2024
  static double calculateINSS(double grossSalary) {
    double inss = 0.0;
    
    if (grossSalary <= 1412.00) {
      inss = grossSalary * 0.075;
    } else if (grossSalary <= 2666.68) {
      inss = (1412.00 * 0.075) + ((grossSalary - 1412.00) * 0.09);
    } else if (grossSalary <= 4000.03) {
      inss = (1412.00 * 0.075) + ((2666.68 - 1412.00) * 0.09) + ((grossSalary - 2666.68) * 0.12);
    } else if (grossSalary <= 7786.02) {
      inss = (1412.00 * 0.075) + ((2666.68 - 1412.00) * 0.09) + ((4000.03 - 2666.68) * 0.12) + ((grossSalary - 4000.03) * 0.14);
    } else {
      // Teto do INSS
      inss = (1412.00 * 0.075) + ((2666.68 - 1412.00) * 0.09) + ((4000.03 - 2666.68) * 0.12) + ((7786.02 - 4000.03) * 0.14);
    }
    
    return inss;
  }

  // Tabela IRRF 2024
  static double calculateIRRF(double grossSalary, double inss, int dependents) {
    double dependentDeduction = dependents * 189.59;
    double baseSalary = grossSalary - inss - dependentDeduction;
    
    // Desconto simplificado (opcional na legislação atual, mas usaremos o cálculo padrão para precisão)
    // double simplifiedDiscount = 564.80;
    // if (inss + dependentDeduction < simplifiedDiscount) {
    //   baseSalary = grossSalary - simplifiedDiscount;
    // }

    double irrf = 0.0;

    if (baseSalary <= 2259.20) {
      irrf = 0.0;
    } else if (baseSalary <= 2826.65) {
      irrf = (baseSalary * 0.075) - 169.44;
    } else if (baseSalary <= 3751.05) {
      irrf = (baseSalary * 0.15) - 381.44;
    } else if (baseSalary <= 4664.68) {
      irrf = (baseSalary * 0.225) - 662.77;
    } else {
      irrf = (baseSalary * 0.275) - 896.00;
    }

    return irrf > 0 ? irrf : 0.0;
  }

  static Map<String, double> calculateNetSalary({
    required double grossSalary,
    required int dependents,
    required double otherDiscounts,
  }) {
    double inss = calculateINSS(grossSalary);
    double irrf = calculateIRRF(grossSalary, inss, dependents);
    double netSalary = grossSalary - inss - irrf - otherDiscounts;

    return {
      'grossSalary': grossSalary,
      'inss': inss,
      'irrf': irrf,
      'otherDiscounts': otherDiscounts,
      'netSalary': netSalary,
    };
  }
}
