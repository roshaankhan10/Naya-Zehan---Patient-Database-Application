import React from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Calendar, User, Phone, MapPin } from 'lucide-react';

export interface Patient {
  id: string;
  name: string;
  fatherName: string;
  surname: string;
  identityNumber: string;
  age: number;
  gender: 'Male' | 'Female';
  phone: string;
  address: string;
  registrationDate: string;
  bloodType: string;
  lastVisit: string;
  condition: string;
  status: 'Active' | 'Inactive' | 'Critical';
}

interface PatientCardProps {
  patient: Patient;
  onClick: (patient: Patient) => void;
}

const PatientCard = ({ patient, onClick }: PatientCardProps) => {
  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Critical': return 'bg-red-100 text-red-800';
      case 'Inactive': return 'bg-gray-100 text-gray-800';
      default: return 'bg-blue-100 text-blue-800';
    }
  };

  return (
    <Card 
      className="hover:shadow-lg transition-all duration-200 cursor-pointer border border-gray-200 hover:border-blue-300 bg-white active:scale-95"
      onClick={() => onClick(patient)}
    >
      <CardContent className="p-5">
        {/* Header */}
        <div className="flex justify-between items-start mb-4">
          <div className="flex-1 min-w-0">
            <h3 className="text-lg font-semibold text-gray-900 truncate">
              {patient.name} {patient.surname}
            </h3>
            <p className="text-sm text-gray-600 truncate">Father: {patient.fatherName}</p>
          </div>
          <Badge className={`${getStatusColor(patient.status)} ml-2 flex-shrink-0`}>
            {patient.status}
          </Badge>
        </div>
        
        {/* Details Grid - Mobile Optimized */}
        <div className="space-y-3 text-sm text-gray-600">
          <div className="flex items-center gap-3">
            <User className="h-4 w-4 flex-shrink-0" />
            <span className="truncate">ID: {patient.identityNumber}</span>
          </div>
          <div className="flex items-center gap-3">
            <Calendar className="h-4 w-4 flex-shrink-0" />
            <span>{patient.age} years, {patient.gender}</span>
          </div>
          <div className="flex items-center gap-3">
            <Phone className="h-4 w-4 flex-shrink-0" />
            <span className="truncate">{patient.phone}</span>
          </div>
          <div className="flex items-center gap-3">
            <MapPin className="h-4 w-4 flex-shrink-0" />
            <span>Blood: {patient.bloodType}</span>
          </div>
        </div>
        
        {/* Footer */}
        <div className="mt-4 pt-4 border-t border-gray-100 space-y-2">
          <p className="text-xs text-gray-600">
            <span className="font-medium">Last Visit:</span> {patient.lastVisit}
          </p>
          <p className="text-xs text-gray-600">
            <span className="font-medium">Registered:</span> {patient.registrationDate}
          </p>
        </div>
      </CardContent>
    </Card>
  );
};

export default PatientCard;
